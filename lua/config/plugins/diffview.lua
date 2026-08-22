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
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Working tree diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repository history" },
    {
      "<leader>gR",
      function()
        vim.ui.input({ prompt = "Review base: ", default = "origin/main" }, function(base)
          if base and base ~= "" then
            vim.cmd("DiffviewOpen " .. base .. "...HEAD")
          end
        end)
      end,
      desc = "Review branch",
    },
  },
  opts = {
    enhanced_diff_hl = true,
    use_icons = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_horizontal" },
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
