local function diagnostic_section(counts, severity, icon)
  local count = counts[severity] or 0
  return count > 0 and (icon .. count) or ""
end

local function active_statusline()
  local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
  local git = MiniStatusline.section_git { trunc_width = 40 }
  local diff = MiniStatusline.section_diff { trunc_width = 75 }
  local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
  local filename = MiniStatusline.section_filename { trunc_width = 140 }
  local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }

  local severity, diagnostics = vim.diagnostic.severity, {}
  if not MiniStatusline.is_truncated(75) then
    local counts = vim.diagnostic.count(0)
    diagnostics = {
      error = diagnostic_section(counts, severity.ERROR, "󰅚 "),
      warn = diagnostic_section(counts, severity.WARN, "󰀪 "),
      info = diagnostic_section(counts, severity.INFO, " "),
      hint = diagnostic_section(counts, severity.HINT, "󰌶 "),
    }
  end

  return MiniStatusline.combine_groups {
    { hl = mode_hl, strings = { mode } },
    { hl = "Directory", strings = { git } },
    { hl = "MiniStatuslineFilename", strings = { diff } },
    "%<",
    { hl = "MiniStatuslineFilename", strings = { filename } },
    "%=",
    { hl = "DiagnosticError", strings = { diagnostics.error } },
    { hl = "DiagnosticWarn", strings = { diagnostics.warn } },
    { hl = "DiagnosticInfo", strings = { diagnostics.info } },
    { hl = "DiagnosticHint", strings = { diagnostics.hint } },
    { hl = "MiniStatuslineFilename", strings = { lsp } },
    { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
  }
end

---@module "lazy"
---@type LazySpec
return {
  "nvim-mini/mini.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("mini.notify").setup()
    local icons = require "mini.icons"
    icons.setup()
    icons.mock_nvim_web_devicons()

    require("mini.git").setup()
    require("mini.diff").setup {
      view = {
        style = "sign",
      },
    }
    require("mini.statusline").setup {
      content = {
        active = active_statusline,
      },
    }

    require("mini.pick").setup()
    require("mini.extra").setup()
    require("mini.files").setup()

    local hipatterns = require "mini.hipatterns"
    hipatterns.setup {
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

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
        delay = 200,
      },
      triggers = {
        { mode = { "n", "x" }, keys = "<Leader>" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "i", keys = "<C-x>" },
        { mode = { "n", "x" }, keys = "g" },
        { mode = { "n", "x" }, keys = "'" },
        { mode = { "n", "x" }, keys = "`" },
        { mode = { "i", "c" }, keys = "<C-r>" },
        { mode = "n", keys = "<C-w>" },
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
        { mode = "n", keys = "<Leader>c", desc = "+Quickfix" },
        { mode = "n", keys = "<Leader>d", desc = "+Diff" },
        { mode = "n", keys = "<Leader>f", desc = "+Find" },
        { mode = "n", keys = "<Leader>g", desc = "+Git" },
        { mode = "n", keys = "<Leader>l", desc = "+LSP" },
        { mode = "n", keys = "<Leader>o", desc = "+Obsidian" },
        { mode = "n", keys = "<Leader>u", desc = "+Toggles" },
      },
    }
  end,
}
