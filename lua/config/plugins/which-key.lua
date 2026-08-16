---@module "lazy"
---@type LazySpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    spec = {
      { "<leader>c", group = "Quickfix" },
      { "<leader>d", group = "Diff" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Hunks", mode = { "n", "v" } },
      { "<leader>l", group = "LSP" },
      { "<leader>n", group = "Notes" },
      { "<leader>o", group = "Obsidian" },
      { "<leader>t", group = "Tests" },
      { "<leader>u", group = "Toggles" },
    },
    plugins = {
      spelling = {
        enabled = true,
      },
    },
  },
}
