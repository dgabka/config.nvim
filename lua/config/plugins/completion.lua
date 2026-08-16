---@module "lazy"
---@type LazySpec
return {
  "saghen/blink.cmp",
  event = "BufReadPre",
  version = "1.*",
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      menu = {
        draw = {
          columns = {
            { "kind_icon" },
            { "label" },
            { "kind" },
          },
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    cmdline = {
      keymap = { preset = "inherit" },
      completion = { menu = { auto_show = true } },
    },
    signature = { enabled = true },
  },
}
