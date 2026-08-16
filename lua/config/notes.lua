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

local commands = { "pull", "push" }

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
  end
end

vim.keymap.set("n", "<leader>np", "<cmd>Notes pull<CR>", { desc = "Pull notes" })
vim.keymap.set("n", "<leader>nP", "<cmd>Notes push<CR>", { desc = "Push notes" })

vim.api.nvim_create_user_command("Notes", function(data)
  if #data.fargs == 0 then
    vim.ui.select(commands, { prompt = "Notes action:" }, function(choice)
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
