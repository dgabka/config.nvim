---@module "lazy"
---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    win_options = {
      foldmethod = { default = "expr", rendered = "expr" },
      foldexpr = {
        default = "v:lua.vim.treesitter.foldexpr()",
        rendered = "v:lua.vim.treesitter.foldexpr()",
      },
    },
  },
}
