require "minimal.options"
require "minimal.lazy"
require "minimal.keymaps"
require "minimal.commands"
require "minimal.diagnostics"
require "minimal.notes"
-- workaround for git diffs to work correctly
vim.opt.diffopt:remove "linematch:40"
