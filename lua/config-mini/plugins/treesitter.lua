---@module "lazy"
---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require "nvim-treesitter"
    treesitter.setup {
      install_dir = vim.fs.joinpath(vim.fn.stdpath "data", "site"),
    }
    treesitter.install {
      "bash",
      "javascript",
      "lua",
      "json",
      "markdown",
      "nix",
      "typescript",
      "vimdoc",
      "yaml",
      "python",
      "html",
      "dockerfile",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "hcl",
      "markdown_inline",
      "mermaid",
      "nginx",
      "rust",
      "sql",
      "ssh_config",
      "terraform",
      "tmux",
      "toml",
      "tsx",
      "zsh",
    }

    local treesitter_group = vim.api.nvim_create_augroup("config_mini_treesitter", { clear = true })

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
  end,
}
