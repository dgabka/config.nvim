local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local checktime_group = augroup("config_autoread_checktime", { clear = true })

autocmd({ "FocusGained", "TermClose", "TermLeave", "CursorHold", "CursorHoldI" }, {
  group = checktime_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "" then
      vim.cmd.checktime()
    end
  end,
})

local notify_group = augroup("config_autoread_notify", { clear = true })

autocmd("FileChangedShellPost", {
  group = notify_group,
  callback = function(event)
    local file = event.file or vim.api.nvim_buf_get_name(event.buf)
    vim.notify(("File reloaded from disk: %s"):format(vim.fn.fnamemodify(file, ":.")), vim.log.levels.INFO)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "norg" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.shiftwidth = 2 -- the number of spaces inserted for each indentation
    vim.opt_local.tabstop = 2 -- insert 2 spaces for a tab
  end,
})

vim.api.nvim_create_user_command("NotesGitPush", function()
  local notes_dir = os.getenv "OBSIDIAN_VAULT"
  if not notes_dir or notes_dir == "" then
    vim.notify("OBSIDIAN_VAULT is not set.", vim.log.levels.ERROR)
    return
  end
  local date = os.date "%Y-%m-%d"
  local commit_msg = date .. " notes"
  -- Save current directory to restore later
  local cwd = vim.fn.getcwd()
  vim.cmd("cd " .. notes_dir)
  vim.cmd "G add ."
  vim.cmd("G commit -m '" .. commit_msg .. "'")
  vim.cmd "G push"
  vim.cmd("cd " .. cwd)
end, { desc = "Stage, commit, and push notes using Fugitive" })
