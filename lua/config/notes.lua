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

  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.cmd.edit(vim.fn.fnameescape(target))

  local ok2 = pcall(vim.cmd.cnext)
  vim.cmd.packadd "cfilter"
  vim.cmd('Cfilter! "' .. file_name .. '"')
  if not ok2 then
    finish_review()
  end
end

-- variables declaration to allow mutual recursion
local pick_dir, create_dir

--- Prompt user to create a new directory, then return to pick_dir
---@param base_path string
---@param bufnr number
function create_dir(base_path, bufnr)
  local rel_path = vim.fs.relative(base_path, notes_dir)
  vim.ui.input({ prompt = "New folder name (relative to " .. rel_path .. "): " }, function(input)
    if not input or input == "" then
      pick_dir(base_path, bufnr)
      return
    end
    local new_dir = vim.fs.joinpath(base_path, input)
    local ok, err = pcall(vim.fn.mkdir, new_dir, "p")
    if not ok then
      vim.notify("Failed to create directory: " .. tostring(err), vim.log.levels.ERROR)
    end
    pick_dir(base_path, bufnr)
  end)
end

--- recursive fn to interactively pick directory
---@param path string
---@param bufnr number
function pick_dir(path, bufnr)
  local selections = {}
  for name, _type in vim.fs.dir(path) do
    if _type == "directory" and string.sub(name, 1, 1) ~= "." and name ~= inbox then
      table.insert(selections, name)
    end
  end
  table.insert(selections, "> here")
  table.insert(selections, "+ new folder")
  vim.ui.select(selections, { prompt = "Move note to:" }, function(choice)
    if not choice then
      return
    end
    if choice == "> here" then
      return move_file(path, bufnr)
    elseif choice == "+ new folder" then
      return create_dir(path, bufnr)
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

--- Move current line to Done (you check an item, hit a keymap, it moves):
local function move_to_done()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

  if not line:match "^%s*%- %[x%]" then
    vim.notify("Not a checked item", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local done_row = nil
  for i, l in ipairs(lines) do
    if l:match "^## Done" then
      done_row = i
      break
    end
  end

  if not done_row then
    vim.notify("No '## Done' section found", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})
  if done_row > row + 1 then
    done_row = done_row - 1
  end
  vim.api.nvim_buf_set_lines(bufnr, done_row, done_row, false, { line })
end

--- Move ALL checked items to Done (bulk cleanup):
local function move_all_to_done()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local done_row = nil
  for i, l in ipairs(lines) do
    if l:match "^## Done" then
      done_row = i
      break
    end
  end

  if not done_row then
    vim.notify("No '## Done' section found", vim.log.levels.WARN)
    return
  end

  local checked, remaining = {}, {}
  for i, l in ipairs(lines) do
    if l:match "^%s*%- %[x%]" and i > done_row then
      -- already in Done, keep it
      table.insert(remaining, l)
    elseif l:match "^%s*%- %[x%]" then
      table.insert(checked, l)
    else
      table.insert(remaining, l)
    end
  end

  -- rebuild: remaining lines, inserting checked items after ## Done
  local result = {}
  for _, l in ipairs(remaining) do
    table.insert(result, l)
    if l:match "^## Done" then
      for _, c in ipairs(checked) do
        table.insert(result, c)
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

vim.keymap.set("n", "<leader>td", move_to_done, { desc = "Move checked item to Done" })
vim.keymap.set("n", "<leader>tD", move_all_to_done, { desc = "Move all checked items to Done" })
