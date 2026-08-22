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
      javascript = { "biome", "prettierd", stop_after_first = true },
      javascriptreact = { "biome", "prettierd", stop_after_first = true },
      typescript = { "biome", "prettierd", stop_after_first = true },
      typescriptreact = { "biome", "prettierd", stop_after_first = true },
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
      biome = { require_cwd = true },
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
