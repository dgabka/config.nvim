local notes_dir = os.getenv "OBSIDIAN_NOTES_DIRECTORY"
local enable_obsidian = notes_dir ~= nil and notes_dir ~= ""

---@module "lazy"
---@type LazySpec
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  enabled = enable_obsidian,
  ft = "markdown",
  cmd = "Obsidian",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "notes",
        path = notes_dir or "~/notes",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",
    daily_notes = {
      folder = "journal",
      default_tags = { "journal" },
    },
  },
}
