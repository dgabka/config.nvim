---@module "lazy"
---@type LazyPluginSpec
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format { async = true, lsp_format = "fallback" }
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      css = { "prettierd" },
      scss = { "prettierd" },
      html = { "prettierd" },
      json = { "prettierd" },
      jsonc = { "prettierd" },
      markdown = { "prettierd" },
      nix = { "alejandra" },
      yaml = { "yamlfmt" },
      bash = { "shfmt" },
      sh = { "shfmt" },
      zsh = { "shfmt" },
      rust = { "rustfmt" },
    },
    formatters = {
      yamlfmt = {
        options = { retain_line_breaks = true },
      },
    },
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "oil" then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
}
