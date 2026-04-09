---@module "lazy"
---@type LazySpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    spec = {
      { "<leader>a", group = "AI", mode = { "n", "v" } },
      { "<leader>c", group = "Quickfix" },
      { "<leader>d", group = "Diff" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Hunks", mode = { "n", "v" } },
      { "<leader>l", group = "LSP" },
      { "<leader>m", group = "Markdown Tasks" },
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
