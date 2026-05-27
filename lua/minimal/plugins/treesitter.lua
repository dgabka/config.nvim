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

    require("treesitter_autoinstall").setup { group = "config_mini_treesitter" }
  end,
}
