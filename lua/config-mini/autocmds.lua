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
