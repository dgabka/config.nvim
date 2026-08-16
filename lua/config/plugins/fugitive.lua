---@module "lazy"
---@type LazySpec
return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gs", "<cmd>0G<CR>", desc = "Git status" },
  },
  cmd = { "Git", "G" },
}
