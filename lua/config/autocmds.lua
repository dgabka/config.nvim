local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local checktime_group = augroup("config_autoread_checktime", { clear = true })

autocmd({ "FocusGained", "BufEnter", "TermClose", "TermLeave" }, {
  group = checktime_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.bo.buftype == "" then
      vim.cmd.checktime()
    end
  end,
})

autocmd("FileChangedShellPost", {
  group = augroup("config_autoread_notify", { clear = true }),
  callback = function(event)
    local file = event.file or vim.api.nvim_buf_get_name(event.buf)
    vim.notify(("File reloaded from disk: %s"):format(vim.fn.fnamemodify(file, ":.")), vim.log.levels.INFO)
  end,
})

autocmd("FileType", {
  pattern = { "markdown", "norg" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.conceallevel = 2
  end,
})
