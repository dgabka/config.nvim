-- We cache the results of "git rev-parse"
local is_inside_work_tree = {}

local function get_theme(name, opts)
  opts = opts or {}
  local defaults = {
    borderchars = {
      prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
      results = { " ", " ", " ", " ", " ", " ", " ", " " },
      preview = { " ", " ", " ", " ", " ", " ", " ", " " },
    },
  }
  local merged = vim.tbl_deep_extend("force", {}, defaults, opts)

  return require("telescope.themes")[name](merged)
end

local function get_ivy(opts)
  return get_theme("get_ivy", opts)
end

local function get_cursor(opts)
  return get_theme("get_cursor", opts)
end

local function get_dropdown(opts)
  return get_theme("get_dropdown", opts)
end

---@module "lazy"
---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
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
          builtin.git_files(get_ivy { show_untracked = true })
        else
          builtin.find_files(get_ivy())
        end
      end,
      desc = "Git files",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").lsp_references(get_cursor { previewer = false })
      end,
      desc = "References",
    },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").lsp_definitions(get_cursor { previewer = false })
      end,
      desc = "Definitions",
    },
    {
      "<leader>ft",
      function()
        require("telescope.builtin").lsp_type_definitions(get_cursor { previewer = false })
      end,
      desc = "Type Definitions",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Grep",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags(get_dropdown())
      end,
      desc = "Help tags",
    },
    {
      "<leader>fo",
      function()
        require("telescope.builtin").oldfiles(get_ivy())
      end,
      desc = "Recent files",
    },
    {
      "<leader>fw",
      function()
        require("telescope.builtin").grep_string()
      end,
      desc = "Word under cursor",
    },
    {
      "<leader>f/",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(get_dropdown())
      end,
      desc = "Search current buffer",
    },
    {
      "<leader>fD",
      function()
        require("telescope.builtin").diagnostics(get_dropdown())
      end,
      desc = "Workspace Diagnostics",
    },
  },
  config = function()
    require("telescope").setup {
      defaults = {
        borderchars = {
          prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
          results = { " ", " ", " ", " ", " ", " ", " ", " " },
          preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
        prompt_prefix = "❯ ",
        selection_caret = "❯ ",
        theme = "ivy",
        mappings = {
          i = { ["<c-d>"] = require("telescope.actions").delete_buffer },
          n = { ["<c-d>"] = require("telescope.actions").delete_buffer },
        },
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
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
        ["ui-select"] = require("telescope.themes").get_cursor {
          previewer = false,
          borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
      },
    }

    require("telescope").load_extension "ui-select"
  end,
}
