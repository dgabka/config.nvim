require "config-mini.options"
require "config-mini.lazy"
require "config-mini.keymaps"
require "config-mini.commands"
require "config-mini.diagnostics"
require "config-mini.autocmds"
require "config-mini.notes"
-- workaround for git diffs to work correctly
vim.opt.diffopt:remove "linematch:40"
