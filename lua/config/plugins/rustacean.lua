---@module "lazy"
---@type LazySpec
return {
  "mrcjkb/rustaceanvim",
  ft = "rust",
  config = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            files = {
              excludeDirs = { ".direnv", "target" },
            },
          },
        },
      },
    }
  end,
}
