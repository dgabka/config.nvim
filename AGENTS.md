# Neovim configuration

Lua configuration deployed to `~/.config/nvim` with GNU Stow.

## Commands

```sh
./stow.sh              # install symlinks
./stow.sh -D           # remove symlinks
stylua --check lua after init.lua
luacheck lua after init.lua
nvim --headless '+checkhealth' +qa
```

## Architecture

- `init.lua` loads `lua/config/init.lua`.
- Core options, mappings, commands, diagnostics, autocmds, and note sync live in `lua/config/`.
- Lazy.nvim automatically imports plugin specs from `lua/config/plugins/`.
- Keep plugin-triggering mappings in their Lazy `keys` specs; keep only group labels in `which-key.lua`.
- Language servers use Neovim's `vim.lsp.config`/`vim.lsp.enable` APIs.
- Formatting is owned by Conform, with LSP formatting only as fallback.
- `$OBSIDIAN_VAULT` enables Obsidian and vault Git synchronization.

## Conventions

- Leader is `<Space>`.
- Optimize for a small, lazy-loaded plugin set and native Neovim features.
- Do not add AI, test-runner, or file-tree plugins.
- Run StyLua and Luacheck after Lua changes.
