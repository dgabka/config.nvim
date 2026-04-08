# obsidian-tasks.nvim

Local Neovim plugin for managing Obsidian task lines from within the editor.

## Features

- Parse and rewrite both metadata styles:
  - emoji markers: `⏫`, `🔼`, `🔽`, `⏬`, `📅`, `➕`, `✅`
  - Dataview inline fields: `[priority:: high]`, `[created:: YYYY-MM-DD]`, `[due:: YYYY-MM-DD]`, `[completion:: YYYY-MM-DD]`, plus preserved extra fields such as `[repeat:: ...]`, `[start:: ...]`, `[scheduled:: ...]`, `[cancelled:: ...]`
- Preserve a task's existing metadata style when editing existing lines
- Default new or style-ambiguous tasks to Dataview metadata
- `:Tasks` command for:
  - `new`
  - `toggle`
  - `status`
  - `priority`
  - `due`
  - `review`
  - `move_done`
  - `move_done_all`
- Quickfix-backed review over the vault using `rg`

## Config

```lua
require("obsidian_tasks").setup {
  vault_root = function()
    return os.getenv "OBSIDIAN_VAULT"
  end,
  metadata_format = "dataview",
  exclude_globs = { ".obsidian/**", "templates/**" },
  done_heading = "## Done",
  done_heading_pattern = "^## Done%s*$",
}
```
