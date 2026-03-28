# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration written in Lua, managed as a dotfiles repo and deployed via GNU Stow.

## Installation

```sh
./stow.sh        # Install (symlinks into ~/.config/nvim)
./stow.sh -D     # Uninstall
```

## Code Style

Lua formatting is enforced by `stylua`. Configuration is in `stylua.toml`. Run via conform.nvim on save, or manually:

```sh
stylua lua/
```

## Architecture

### Entry Point

`init.lua` → `lua/config/init.lua`, which loads in order:
1. `options.lua` — editor settings
2. `lazy.lua` — bootstraps and initializes lazy.nvim
3. `keymaps.lua` — global keybindings
4. `diagnostics.lua` — LSP diagnostic display
5. `autocmds.lua` — autocommands
6. `notes.lua` — Obsidian note management (`:Notes` command)

### Plugin System

Plugins are managed by `lazy.nvim`. Each plugin has its own file in `lua/config/plugins/`. The spec directory is auto-imported by lazy.nvim — adding a new `.lua` file there is sufficient to register a plugin.

### Utilities

- `lua/config/utils/host.lua` — hostname-based environment detection (`is_work()`, `is_home()`, `is_lab()`). Used to conditionally configure tools per machine (e.g., AI provider selection in `codecompanion.lua`).
- `lua/config/utils/str_utils.lua` — `slugify()` for kebab-case note IDs used by Obsidian.

### Filetype Overrides

`after/ftplugin/` contains filetype-specific Lua files (rust, java, haskell, sh). These are loaded by Neovim automatically after the main config.

### Notes System

`lua/config/notes.lua` implements a custom note management workflow on top of Obsidian:
- Requires `OBSIDIAN_VAULT` environment variable pointing to the vault directory.
- `:Notes pull|push|review` commands for git sync and inbox review.
- Interactive directory picker for moving notes between folders.

### Environment-Aware Config

`codecompanion.lua` uses `host.lua` to select different AI adapters: `codex` adapter at work, `claude_code` at home. When adding machine-specific behavior, use the `is_work()`/`is_home()`/`is_lab()` helpers.

## Key Conventions

- Leader key is `<space>`.
- LSP servers are configured in `lua/config/plugins/lspconfig.lua`. Formatters are in `lua/config/plugins/conform.lua` (format-on-save, 500ms timeout).
- Treesitter is the folding provider (`foldexpr=nvim_treesitter#foldexpr()`), foldlevel 99.
- Completion is handled by `blink.cmp` with Copilot as an additional source via `blink-copilot`.
- Copilot suggestions/panel are disabled; Copilot is used only as a blink.cmp completion source.
