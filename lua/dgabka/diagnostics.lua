vim.diagnostic.config {
  virtual_text = true,
  update_in_insert = true,
  severity_sort = false,
  float = {
    header = "",
    border = "solid",
    style = "minimal",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
}
