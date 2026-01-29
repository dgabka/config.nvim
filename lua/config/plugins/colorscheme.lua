---@module "lazy"
---@type LazySpec
return {
  {
    "sageveil/nvim",
    -- dir = "~/repos/sageveil/dist/ports/nvim/",
    name = "sageveil",
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
  },
  {
    "norcalli/nvim-colorizer.lua",
  },
}
