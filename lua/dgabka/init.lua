vim.cmd [[let &t_Cs = "\e[4:3m"]]
vim.cmd [[let &t_Ce = "\e[4:0m"]]
vim.cmd "let g:tinted_italic = 0"

require "dgabka.options"
require "dgabka.lazy"
require "dgabka.keymaps"
require "dgabka.diagnostics"
require "dgabka.autocmds"
require "dgabka.lualine-codecompanion-ext"
