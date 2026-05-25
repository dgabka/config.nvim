---@module "lazy"
---@type LazySpec
return {
  "nvim-mini/mini.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("mini.notify").setup()
    require("mini.icons").setup()

    require("mini.git").setup()
    require("mini.diff").setup {
      view = {
        style = 'sign',
      }
    }
    require("mini.statusline").setup()

    require("mini.pick").setup()
    require("mini.extra").setup()
    require("mini.files").setup()

    local hipatterns = require "mini.hipatterns"
    hipatterns.setup {
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    require("mini.ai").setup()
    require("mini.bracketed").setup()
    require("mini.move").setup()
    require("mini.surround").setup()
    require("mini.sessions").setup()

    local gen_loader = require("mini.snippets").gen_loader
    local snippet_dir = vim.fn.stdpath "config" .. "/snippets"
    require("mini.snippets").setup {
      snippets = {
        gen_loader.from_file(vim.fs.joinpath(snippet_dir, "markdown.json")),
        gen_loader.from_file(vim.fs.joinpath(snippet_dir, "js.json")),
        gen_loader.from_file(vim.fs.joinpath(snippet_dir, "ts.json")),
        gen_loader.from_lang(),
      },
    }
    MiniSnippets.start_lsp_server { match = false }
    require("mini.completion").setup()

    local clue = require "mini.clue"
    clue.setup {
      window = {
        delay = 200
      },
      triggers = {
        { mode = { "n", "x" }, keys = "<Leader>" },
        { mode = "n",          keys = "[" },
        { mode = "n",          keys = "]" },
        { mode = "i",          keys = "<C-x>" },
        { mode = { "n", "x" }, keys = "g" },
        { mode = { "n", "x" }, keys = "'" },
        { mode = { "n", "x" }, keys = "`" },
        { mode = { "i", "c" }, keys = "<C-r>" },
        { mode = "n",          keys = "<C-w>" },
        { mode = { "n", "x" }, keys = "z" },
      },
      clues = {
        clue.gen_clues.square_brackets(),
        clue.gen_clues.builtin_completion(),
        clue.gen_clues.g(),
        clue.gen_clues.marks(),
        clue.gen_clues.registers(),
        clue.gen_clues.windows(),
        clue.gen_clues.z(),
        { mode = "n",          keys = "<Leader>c", desc = "+Quickfix" },
        { mode = "n",          keys = "<Leader>d", desc = "+Diff" },
        { mode = "n",          keys = "<Leader>g", desc = "+Git" },
        { mode = "n",          keys = "<Leader>l", desc = "+LSP" },
        { mode = { "n", "x" }, keys = "<Leader>m", desc = "+Markdown Tasks" },
        { mode = "n",          keys = "<Leader>n", desc = "+Notes" },
        { mode = "n",          keys = "<Leader>o", desc = "+Obsidian" },
        { mode = "n",          keys = "<Leader>t", desc = "+Tests" },
        { mode = "n",          keys = "<Leader>u", desc = "+Toggles" },
      },
    }
  end,
}
