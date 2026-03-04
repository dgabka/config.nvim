require "config.options"
require "config.lazy"
require "config.keymaps"
require "config.diagnostics"
require "config.autocmds"
require "config.lualine-codecompanion-ext"
require "config.notes"
-- workaround for git diffs to work correctly
vim.opt.diffopt:remove "linematch:40"
