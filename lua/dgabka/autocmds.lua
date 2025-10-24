local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local checktime_group = augroup("dgabka_autoread_checktime", { clear = true })

autocmd({ "FocusGained", "TermClose", "TermLeave", "CursorHold", "CursorHoldI" }, {
  group = checktime_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "" then
      vim.cmd.checktime()
    end
  end,
})

local notify_group = augroup("dgabka_autoread_notify", { clear = true })

autocmd("FileChangedShellPost", {
  group = notify_group,
  callback = function(event)
    local file = event.file or vim.api.nvim_buf_get_name(event.buf)
    vim.notify(("File reloaded from disk: %s"):format(vim.fn.fnamemodify(file, ":.")), vim.log.levels.INFO)
  end,
})
