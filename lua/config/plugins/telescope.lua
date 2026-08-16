local is_inside_work_tree = {}

---@module "lazy"
---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-lua/plenary.nvim",
    {
      "nvim-tree/nvim-web-devicons",
      opts = {
        color_icons = false,
        default = true,
        strict = true,
      },
    },
  },
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        local builtin = require "telescope.builtin"
        local cwd = vim.fn.getcwd()
        if is_inside_work_tree[cwd] == nil then
          vim.fn.system "git rev-parse --is-inside-work-tree"
          is_inside_work_tree[cwd] = vim.v.shell_error == 0
        end
        if is_inside_work_tree[cwd] then
          builtin.git_files { show_untracked = true }
        else
          builtin.find_files()
        end
      end,
      desc = "Files",
    },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
    { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Word under cursor" },
    { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Current buffer" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
    { "<leader>fc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    { "<leader>fC", "<cmd>Telescope git_bcommits<CR>", desc = "File commits" },
  },
  config = function()
    require("telescope").setup {
      defaults = {
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt_prefix = "❯ ",
        selection_caret = "❯ ",
        path_display = { "smart" },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
          "--trim",
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = require("telescope.themes").get_cursor { previewer = false },
      },
    }
    require("telescope").load_extension "fzf"
    require("telescope").load_extension "ui-select"
  end,
}
