---@module "lazy"
---@type LazySpec
return {
  -- "sageveil/nvim",
  dir = "~/repos/sageveil.git/main/dist/ports/nvim",
  name = "sageveil",
  lazy = false,
  priority = 1000,
  config = function()
    require("sageveil").setup {
      style = {
        italic = false,
        transparent = false,
      },
    }
    vim.cmd.colorscheme "sageveil"
  end,
  dependencies = {
    "norcalli/nvim-colorizer.lua",
  },
}
