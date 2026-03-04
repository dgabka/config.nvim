---@module "lazy"
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFocusFiles",
    "DiffviewToggleFiles",
    "DiffviewFileHistory",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
    { "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (Diffview)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history (Diffview)" },
  },
  opts = {
    enhanced_diff_hl = true,
    use_icons = true,
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_horizontal",
      },
    },
    file_panel = {
      listing_style = "tree",
      win_config = {
        position = "left",
        width = 40,
      },
    },
  },
}
