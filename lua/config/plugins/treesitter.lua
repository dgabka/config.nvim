---@module "lazy"
---@type LazySpec
return {
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

    local function enable(buf)
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and pcall(vim.treesitter.start, buf) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
      callback = function(event)
        enable(event.buf)
      end,
    })

    treesitter
      .install({
        "bash",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "javascript",
        "json",
        "just",
        "lua",
        "markdown",
        "markdown_inline",
        "mermaid",
        "nix",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vimdoc",
        "yaml",
        "zsh",
      })
      :await(function(err)
        if not err then
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              enable(buf)
            end
          end)
        end
      end)

    require("nvim-treesitter-textobjects").setup {
      select = { lookahead = true },
      move = { set_jumps = true },
    }

    local select = require "nvim-treesitter-textobjects.select"
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

    local move = require "nvim-treesitter-textobjects.move"
    local move_mappings = {
      ["]f"] = { "goto_next_start", "@function.outer" },
      ["[f"] = { "goto_previous_start", "@function.outer" },
    }
    for _, mode in ipairs { "n", "x", "o" } do
      for lhs, mapping in pairs(move_mappings) do
        vim.keymap.set(mode, lhs, function()
          move[mapping[1]](mapping[2], "textobjects")
        end, { desc = ("Treesitter %s"):format(mapping[2]) })
      end
    end
  end,
}
