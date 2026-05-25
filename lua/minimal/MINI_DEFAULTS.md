# Mini.nvim Defaults Used By This Profile

This profile mostly calls `setup()` with no overrides for Mini modules. The few explicit additions are:

- `mini.clue`: triggers are required because it has none by default.
- `mini.hipatterns`: `hex_color` is enabled to replace color highlighting.
- `mini.snippets`: local `snippets/*.json` files are loaded because Mini has no snippets by default.
- `mini.snippets`: its snippet LSP server is started so snippets appear through `mini.completion`.
- `mini.icons`: `mock_nvim_web_devicons()` is called for copied plugins that still ask for devicons.
- Colorscheme: `sageveil` is copied over because Mini does not replace the custom theme.

Docs: https://nvim-mini.org/mini.nvim/doc/mini-nvim.html

## mini.ai

Default settings:

```lua
{
  custom_textobjects = nil,
  mappings = {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
    goto_left = "g[",
    goto_right = "g]",
  },
  n_lines = 50,
  search_method = "cover_or_next",
  silent = false,
}
```

Default textobject ids include brackets, quotes, function call (`f`), argument (`a`), tag (`t`), prompt (`?`), and separators.

## mini.bracketed

Default targets create `[X`, `[x`, `]x`, and `]X` style mappings, where lowercase moves backward/forward and uppercase goes first/last.

```lua
{
  buffer = { suffix = "b" },
  comment = { suffix = "c" },
  conflict = { suffix = "x" },
  diagnostic = { suffix = "d" },
  file = { suffix = "f" },
  indent = { suffix = "i" },
  jump = { suffix = "j" },
  location = { suffix = "l" },
  oldfile = { suffix = "o" },
  quickfix = { suffix = "q" },
  treesitter = { suffix = "t" },
  undo = { suffix = "u" },
  window = { suffix = "w" },
  yank = { suffix = "y" },
}
```

## mini.clue

Defaults:

```lua
{
  clues = {},
  triggers = {},
  window = {
    config = {},
    delay = 1000,
    scroll_down = "<C-d>",
    scroll_up = "<C-u>",
  },
}
```

This profile adds starter triggers for `<Leader>`, `[`, `]`, `<C-x>`, `g`, marks, registers, `<C-w>`, and `z`, plus group labels for existing leader namespaces.

## mini.completion

Default settings:

```lua
{
  delay = { completion = 100, info = 100, signature = 50 },
  window = {
    info = { height = 25, width = 80, border = nil },
    signature = { height = 25, width = 80, border = nil },
  },
  lsp_completion = {
    source_func = "completefunc",
    auto_setup = true,
    process_items = nil,
    snippet_insert = nil,
  },
  fallback_action = "<C-n>",
  mappings = {
    force_twostep = "<C-Space>",
    force_fallback = "<A-Space>",
    scroll_down = "<C-f>",
    scroll_up = "<C-b>",
  },
}
```

Popup navigation uses Neovim built-in insert completion mappings, such as `<C-n>`, `<C-p>`, and `<C-y>`.

## mini.diff

Default settings and mappings:

```lua
{
  view = {
    style = vim.go.number and "number" or "sign",
    signs = { add = "▒", change = "▒", delete = "▒" },
    priority = 199,
  },
  source = nil,
  delay = { text_change = 200 },
  mappings = {
    apply = "gh",
    reset = "gH",
    textobject = "gh",
    goto_first = "[H",
    goto_prev = "[h",
    goto_next = "]h",
    goto_last = "]H",
  },
  options = {
    algorithm = "histogram",
    indent_heuristic = true,
    linematch = 60,
    wrap_goto = false,
  },
}
```

With the default Git source, apply means staging hunks and reset means restoring from the reference text.

## mini.files

Default settings:

```lua
{
  content = {
    filter = nil,
    highlight = nil,
    prefix = nil,
    sort = nil,
  },
  mappings = {
    close = "q",
    go_in = "l",
    go_in_plus = "L",
    go_out = "h",
    go_out_plus = "H",
    mark_goto = "'",
    mark_set = "m",
    reset = "<BS>",
    reveal_cwd = "@",
    show_help = "g?",
    synchronize = "=",
    trim_left = "<",
    trim_right = ">",
  },
  options = {
    permanent_delete = true,
    use_as_default_explorer = true,
    lsp_timeout = 1000,
  },
  windows = {
    max_number = math.huge,
    preview = false,
    width_focus = 50,
    width_nofocus = 15,
    width_preview = 25,
  },
}
```

No global opener mapping is created by default. Use `:lua MiniFiles.open()`.

## mini.git

Defaults:

```lua
{
  job = {
    git_executable = "git",
    timeout = 30000,
  },
  command = {
    split = "auto",
  },
}
```

Setup creates `:Git`.

## mini.hipatterns

Defaults:

```lua
{
  highlighters = {},
  delay = {
    text_change = 200,
    scroll = 50,
  },
}
```

This profile adds `hex_color = hipatterns.gen_highlighter.hex_color()`.

## mini.icons

Defaults:

```lua
{
  style = "glyph",
  default = {},
  directory = {},
  extension = {},
  file = {},
  filetype = {},
  lsp = {},
  os = {},
  use_file_extension = function(ext, file) return true end,
}
```

No keymaps.

## mini.move

Defaults:

```lua
{
  mappings = {
    left = "<M-h>",
    right = "<M-l>",
    down = "<M-j>",
    up = "<M-k>",
    line_left = "<M-h>",
    line_right = "<M-l>",
    line_down = "<M-j>",
    line_up = "<M-k>",
  },
  options = {
    reindent_linewise = true,
  },
}
```

## mini.notify

Defaults:

```lua
{
  content = {
    format = nil,
    sort = nil,
  },
  lsp_progress = {
    enable = true,
    level = "INFO",
    duration_last = 1000,
  },
  window = {
    config = {},
    max_width_share = 0.382,
    winblend = 25,
  },
}
```

Setup replaces `vim.notify`.

## mini.pick

Default action mappings:

```lua
{
  caret_left = "<Left>",
  caret_right = "<Right>",
  choose = "<CR>",
  choose_in_split = "<C-s>",
  choose_in_tabpage = "<C-t>",
  choose_in_vsplit = "<C-v>",
  choose_marked = "<M-CR>",
  delete_char = "<BS>",
  delete_char_right = "<Del>",
  delete_left = "<C-u>",
  delete_word = "<C-w>",
  mark = "<C-x>",
  mark_all = "<C-a>",
  move_down = "<C-n>",
  move_start = "<C-g>",
  move_up = "<C-p>",
  paste = "<C-r>",
  refine = "<C-Space>",
  refine_marked = "<M-Space>",
  scroll_down = "<C-f>",
  scroll_left = "<C-h>",
  scroll_right = "<C-l>",
  scroll_up = "<C-b>",
  stop = "<Esc>",
  toggle_info = "<S-Tab>",
  toggle_preview = "<Tab>",
}
```

Other defaults:

```lua
{
  delay = { async = 10, busy = 50 },
  options = { content_from_bottom = false, use_cache = false },
  source = {
    items = nil,
    name = nil,
    cwd = nil,
    match = nil,
    show = nil,
    preview = nil,
    choose = nil,
    choose_marked = nil,
  },
  window = {
    config = nil,
    prompt_caret = "▏",
    prompt_prefix = "> ",
  },
}
```

Setup creates `:Pick` and sets `vim.ui.select`.

## mini.sessions

Defaults:

```lua
{
  autoread = false,
  autowrite = true,
  directory = "<stdpath('data')>/session",
  file = "Session.vim",
  force = { read = false, write = true, delete = false },
  hooks = {
    pre = { read = nil, write = nil, delete = nil },
    post = { read = nil, write = nil, delete = nil },
  },
  verbose = { read = false, write = true, delete = true },
}
```

No keymaps.

## mini.snippets

Defaults:

```lua
{
  snippets = {},
  mappings = {
    expand = "<C-j>",
    jump_next = "<C-l>",
    jump_prev = "<C-h>",
    stop = "<C-c>",
  },
  expand = {
    prepare = nil,
    match = nil,
    select = nil,
    insert = nil,
  },
}
```

## mini.statusline

Defaults:

```lua
{
  content = {
    active = nil,
    inactive = nil,
  },
  use_icons = true,
}
```

No keymaps.

## mini.surround

Defaults:

```lua
{
  custom_surroundings = nil,
  highlight_duration = 500,
  mappings = {
    add = "sa",
    delete = "sd",
    find = "sf",
    find_left = "sF",
    highlight = "sh",
    replace = "sr",
    suffix_last = "l",
    suffix_next = "n",
  },
  n_lines = 20,
  respect_selection_type = false,
  search_method = "cover",
  silent = false,
}
```

## mini.extra

No persistent default settings or keymaps. Setup registers extra `mini.pick` pickers such as buffer lines, colorschemes, commands, diagnostics, explorer, git files, keymaps, lists, locations, marks, old files, options, registers, spelling, treesitter, and visits.
