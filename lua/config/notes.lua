local inbox = "00-inbox"
local notes_dir = os.getenv "OBSIDIAN_VAULT"

-- do not load if OBSIDIAN_VAULT not available
if not notes_dir or notes_dir == "" then
  return
end

local home_dir = os.getenv "HOME"
local cwd = vim.fn.getcwd()
local cwd_relative = home_dir ~= nil and string.gsub(cwd, home_dir, "~") or cwd

-- do not load outside of OBSIDIAN_VAULT
if cwd ~= notes_dir and cwd_relative ~= notes_dir then
  return
end

local function pull_notes()
  vim.cmd "G stash push -m ':Notes pull stash'"
  vim.cmd "G pull"
  vim.cmd "G stash pop"
end

local function push_notes()
  local date = os.date "%Y-%m-%d"
  local commit_msg = date .. " notes"
  vim.cmd "G add ."
  vim.cmd("G commit -m '" .. commit_msg .. "'")
  vim.cmd "G push"
end

---@param file_name string of the file to add
local file_to_qflist = function(file_name)
  local file_path = vim.fs.joinpath(inbox, file_name)
  local bufnr = vim.fn.bufadd(file_path)
  vim.fn.bufload(bufnr)

  return {
    bufnr = bufnr,
    lnum = 2,
    col = 1,
    text = file_name,
  }
end

local function finish_review()
  vim.keymap.del("n", "<leader>nm")
  vim.keymap.del("n", "<leader>nd")
  vim.keymap.del("n", "<leader>nr")
  vim.keymap.del("n", "<leader>fr")
  pcall(vim.cmd.cclose)
end

local function delete_note()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local file_name = vim.fs.basename(file_path)
  local ok = pcall(vim.cmd.cnext)
  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.fs.rm(file_path)
  vim.cmd.packadd "cfilter"
  vim.cmd('Cfilter! "' .. file_name .. '"')
  if not ok then
    finish_review()
  end
end

--- move file in buffer to target directory
---@param target_dir string
---@param bufnr number
local function move_file(target_dir, bufnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local file_name = vim.fs.basename(file_path)
  local target = vim.fs.joinpath(target_dir, file_name)
  vim.cmd "update" -- save changes
  local ok, err = os.rename(file_path, target)
  if not ok then
    vim.notify("Move failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_name(bufnr, target)
  vim.cmd.edit(vim.fn.fnameescape(target))

  local ok2 = pcall(vim.cmd.cnext)
  vim.cmd.packadd "cfilter"
  vim.cmd('Cfilter! "' .. file_name .. '"')
  if not ok2 then
    finish_review()
  end
end

--- recursive fn to interactively pick directory
---@param path string
---@param bufnr number
local function pick_dir(path, bufnr)
  local selections = {}
  for name, _type in vim.fs.dir(path) do
    if _type == "directory" and string.sub(name, 1, 1) ~= "." and name ~= inbox then
      table.insert(selections, name)
    end
  end
  -- TODO: consider possibility of adding directories
  -- table.insert(selections, "New folder")
  table.insert(selections, "> here")
  vim.ui.select(selections, { prompt = "Move note to:" }, function(choice)
    if not choice then
      return
    end
    if choice == "> here" then
      return move_file(path, bufnr)
    else
      return pick_dir(vim.fs.joinpath(path, choice), bufnr)
    end
  end)
end

local function move_note()
  local bufnr = vim.api.nvim_get_current_buf()
  pick_dir(cwd, bufnr)
end

local function review_inbox()
  local inbox_notes = {}
  local len = 0

  for name, _type in vim.fs.dir(inbox) do
    if _type == "file" and name:match "%.md$" then
      table.insert(inbox_notes, file_to_qflist(name))
      len = len + 1
    end
  end

  if len == 0 then
    vim.notify("Inbox is empty!", vim.log.levels.INFO)
    return
  end

  vim.keymap.set("n", "<leader>nm", move_note, { desc = "Move note" })
  vim.keymap.set("n", "<leader>nd", delete_note, { desc = "Delete note" })
  vim.keymap.set("n", "<leader>nr", function()
    vim.cmd "CodeCompanion /review-note"
  end, { desc = "Delete note" })
  vim.keymap.set("n", "<leader>fr", finish_review, { desc = "Finish review" })

  vim.fn.setqflist(inbox_notes, " ")
  vim.fn.setqflist({}, "a", { title = "Inbox" })
  vim.cmd.copen()
  vim.cmd.cfirst()
end

local commands = { "pull", "push", "review" }

local function notes_complete(arglead)
  -- return all commands that start with current arglead
  return vim.tbl_filter(function(cmd)
    return cmd:find("^" .. vim.pesc(arglead))
  end, commands)
end

local function run_command(cmd)
  if cmd == "pull" then
    pull_notes()
  elseif cmd == "push" then
    push_notes()
  elseif cmd == "review" then
    review_inbox()
  end
end

vim.api.nvim_create_user_command("Notes", function(data)
  if #data.fargs == 0 then
    vim.ui.select(commands, { prompt = "Move note to:" }, function(choice)
      if not choice then
        return
      end
      run_command(choice)
    end)
    return
  end
  local cmd = data.fargs[1]
  run_command(cmd)
end, {
  nargs = "*",
  complete = notes_complete,
})
