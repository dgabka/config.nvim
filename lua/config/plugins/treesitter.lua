---@module "lazy"
---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
    },
    config = function()
      local treesitter = require "nvim-treesitter"
      treesitter.setup {
        install_dir = vim.fs.joinpath(vim.fn.stdpath "data", "site"),
      }

      local treesitter_group = vim.api.nvim_create_augroup("config_treesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = treesitter_group,
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "" then
            return
          end

          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            return
          end

          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require "nvim-treesitter-textobjects.select"

      if select then
        local select_mappings = {
          af = "@function.outer",
          ["if"] = "@function.inner",
          ai = "@conditional.outer",
          ii = "@conditional.inner",
        }

        for _, mode in ipairs { "x", "o" } do
          for lhs, capture in pairs(select_mappings) do
            vim.keymap.set(mode, lhs, function()
              select.select_textobject(capture, "textobjects")
            end, { desc = ("Treesitter %s"):format(capture) })
          end
        end
      end

      local move = require "nvim-treesitter-textobjects.move"

      if move then
        local move_mappings = {
          ["]f"] = {
            method = "goto_next_start",
            capture = "@function.outer",
          },
          ["[f"] = {
            method = "goto_previous_start",
            capture = "@function.outer",
          },
        }

        for _, mode in ipairs { "n", "x", "o" } do
          for lhs, mapping in pairs(move_mappings) do
            vim.keymap.set(mode, lhs, function()
              move[mapping.method](mapping.capture, "textobjects")
            end, { desc = ("Treesitter %s"):format(mapping.capture) })
          end
        end
      end
    end,
  },
}
