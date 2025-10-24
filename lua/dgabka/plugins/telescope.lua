-- We cache the results of "git rev-parse"
local is_inside_work_tree = {}

---@module "lazy"
---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-lua/plenary.nvim",
  },
  lazy = false,
  cmd = "Telescope",
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

    local function get_ivy(opts)
      opts = opts or {}
      local defaults = {
        borderchars = {
          prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
          results = { " ", " ", " ", " ", " ", " ", " ", " " },
          preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
      }
      local merged = vim.tbl_deep_extend("force", {}, defaults, opts)

      return require("telescope.themes").get_ivy(merged)
    end

    local function get_cursor(opts)
      opts = opts or {}
      local defaults = {
        borderchars = {
          prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
          results = { " ", " ", " ", " ", " ", " ", " ", " " },
          preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
      }
      local merged = vim.tbl_deep_extend("force", {}, defaults, opts)

      return require("telescope.themes").get_cursor(merged)
    end

    local function get_dropdown(opts)
      opts = opts or {}
      local defaults = {
        borderchars = {
          prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
          results = { " ", " ", " ", " ", " ", " ", " ", " " },
          preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
      }
      local merged = vim.tbl_deep_extend("force", {}, defaults, opts)

      return require("telescope.themes").get_dropdown(merged)
    end

    require("telescope").load_extension "ui-select"

    local builtin = require "telescope.builtin"
    vim.keymap.set("n", "<leader>ff", function()
      local cwd = vim.fn.getcwd()
      if is_inside_work_tree[cwd] == nil then
        vim.fn.system "git rev-parse --is-inside-work-tree"
        is_inside_work_tree[cwd] = vim.v.shell_error == 0
      end

      if is_inside_work_tree[cwd] then
        builtin.git_files(get_ivy { show_untracked = false })
      else
        builtin.find_files(get_ivy())
      end
    end, { desc = "Git files" })
    vim.keymap.set("n", "<leader>fr", function()
      builtin.lsp_references(get_cursor { previewer = false })
    end, { desc = "References" })
    vim.keymap.set("n", "<leader>fd", function()
      builtin.lsp_definitions(get_cursor { previewer = false })
    end, { desc = "Definitions" })
    vim.keymap.set("n", "<leader>ft", function()
      builtin.lsp_type_definitions(get_cursor { previewer = false })
    end, { desc = "Type Definitions" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>fD", function()
      builtin.diagnostics(get_dropdown())
    end, { desc = "Workspace Diagnostics" })
  end,
}
