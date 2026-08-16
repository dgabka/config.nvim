---@module "lazy"
---@type LazySpec
return {
  "sageveil/nvim",
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
}
