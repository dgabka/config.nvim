local notes_dir = os.getenv "OBSIDIAN_VAULT"
if not notes_dir or notes_dir == "" then
  return
end

notes_dir = vim.uv.fs_realpath(notes_dir) or notes_dir
local cwd = vim.uv.fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()
local relative = vim.fs.relpath(notes_dir, cwd)
if not relative or relative == ".." or vim.startswith(relative, ".." .. package.config:sub(1, 1)) then
  return
end

local function pull_notes()
  vim.cmd "G pull --rebase --autostash"
end

local function push_notes()
  vim.cmd "G add ."
  vim.cmd("G commit -m '" .. os.date "%Y-%m-%d" .. " notes'")
  vim.cmd "G push"
end

local commands = { "pull", "push" }

local function run_command(command)
  if command == "pull" then
    pull_notes()
  elseif command == "push" then
    push_notes()
  end
end

vim.keymap.set("n", "<leader>np", "<cmd>Notes pull<CR>", { desc = "Pull notes" })
vim.keymap.set("n", "<leader>nP", "<cmd>Notes push<CR>", { desc = "Push notes" })

vim.api.nvim_create_user_command("Notes", function(data)
  if #data.fargs > 0 then
    run_command(data.fargs[1])
    return
  end
  vim.ui.select(commands, { prompt = "Notes action:" }, function(choice)
    if choice then
      run_command(choice)
    end
  end)
end, {
  nargs = "?",
  complete = function(arglead)
    return vim.tbl_filter(function(command)
      return vim.startswith(command, arglead)
    end, commands)
  end,
})
