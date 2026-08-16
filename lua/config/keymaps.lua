local set = vim.keymap.set

set("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix" })
set("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Close quickfix" })

set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
set("v", "<leader>y", [["+y]], { desc = "Yank to clipboard" })
set("n", "<leader>y", [["+Y]], { desc = "Yank line to clipboard" })

set("n", "<leader>ui", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

set("n", "<leader>ud", function()
  local enabled = vim.diagnostic.config().virtual_lines ~= false
  vim.diagnostic.config { virtual_lines = enabled and false or { current_line = true } }
end, { desc = "Toggle diagnostic lines" })

set("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })

set("n", "<CR>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd.nohlsearch()
    return ""
  end
  return vim.keycode "<CR>"
end, { expr = true, desc = "Clear search or enter" })

set("n", "<leader>dl", "<cmd>%diffget _LOCAL_<CR>", { desc = "Pick local changes" })
set("n", "<leader>dr", "<cmd>%diffget _REMOTE_<CR>", { desc = "Pick remote changes" })
