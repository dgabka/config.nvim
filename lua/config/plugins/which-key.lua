local groups = {
  { "<leader>c", group = "Quickfix" },
  { "<leader>d", group = "Diff" },
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>h", group = "Hunks", mode = { "n", "v" } },
  { "<leader>l", group = "LSP" },
  { "<leader>u", group = "Toggles" },
}

local vault = os.getenv "OBSIDIAN_VAULT"
if vault and vault ~= "" then
  vim.list_extend(groups, {
    { "<leader>n", group = "Notes" },
    { "<leader>o", group = "Obsidian" },
  })
end

---@module "lazy"
---@type LazySpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    spec = groups,
    plugins = {
      spelling = { enabled = true },
    },
  },
}
