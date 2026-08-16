vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = { current_line = true },
  update_in_insert = false,
  severity_sort = true,
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
