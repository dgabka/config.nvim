local notes_dir = os.getenv "OBSIDIAN_VAULT"
local enable_obsidian = notes_dir ~= nil and notes_dir ~= ""
local date_format = "%Y-%m-%d"
local time_format = "%H:%M"
local date_time_format = date_format .. " " .. time_format

---@module "lazy"
---@type LazySpec
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  enabled = enable_obsidian,
  ft = "markdown",
  cmd = "Obsidian",
  keys = {
    -- Quick switcher / find notes
    { "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian Find notes" },
    -- Search in notes
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian Search" },
    -- Daily notes
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Obsidian Today" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Obsidian Yesterday" },
    { "<leader>om", "<cmd>Obsidian tomorrow<cr>", desc = "Obsidian Tomorrow" },
    -- Create new note
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian New note" },
    { "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "Obsidian New from template" },
    -- Template
    { "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Obsidian Template" },
    -- Smart action (follow link, toggle checkbox, etc.)
    { "<cr>", "<cmd>Obsidian smart_action<cr>", desc = "Obsidian smart action", ft = "markdown" },
    -- Navigate links
    { "]o", "<cmd>Obsidian nav_link next<cr>", desc = "Next obsidian link", ft = "markdown" },
    { "[o", "<cmd>Obsidian nav_link prev<cr>", desc = "Previous obsidian link", ft = "markdown" },
    -- Backlinks
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian Backlinks" },
    -- Tags
    { "<leader>ogt", "<cmd>Obsidian tags<cr>", desc = "Obsidian Tags" },
    -- Links
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Obsidian Links" },
    -- Rename note
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Obsidian Rename" },
    -- Toggle checkbox
    { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian toggle Checkbox" },
    -- Open in Obsidian app
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Obsidian Open in app" },
    -- Paste image
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Obsidian Paste image" },
    -- Table of contents
    { "<leader>otc", "<cmd>Obsidian toc<cr>", desc = "Obsidian Table of Contents" },
    -- Workspace
    { "<leader>ow", "<cmd>Obsidian workspace<cr>", desc = "Obsidian Workspace" },
  },
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
    notes_subdir = "00-inbox",
    new_notes_location = "notes_subdir",
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil and title ~= "" then
        -- Slugify the title: lowercase, replace spaces/special chars with hyphens
        suffix = title
          :lower()
          :gsub("[^%w%s-]", "") -- Remove special characters except spaces and hyphens
          :gsub("%s+", "-") -- Replace spaces with hyphens
          :gsub("-+", "-") -- Replace multiple hyphens with single hyphen
          :gsub("^-+", "") -- Remove leading hyphens
          :gsub("-+$", "") -- Remove trailing hyphens
      else
        -- Generate random suffix if no title
        for _ = 1, 6 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return os.date(date_format) .. "_" .. suffix
    end,
    daily_notes = {
      folder = "40-journal",
      default_tags = { "journal" },
    },
    templates = {
      subdir = "templates",
      date_format = date_format,
      time_format = time_format,
    },
    completion = {
      blink = true,
      min_chars = 2,
      match_case = true,
      create_new = true,
    },
    picker = {
      name = "telescope.nvim",
    },
    frontmatter = {
      enabled = true,
      sort = { "id", "aliases", "tags", "created", "updated" },
      func = function(note)
        local out = {
          id = note.id,
          created = os.date(date_time_format),
          aliases = note.aliases,
          tags = note.tags,
        }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        out.updated = os.date(date_time_format)
        return out
      end,
    },
    ui = {
      enable = false,
      hl_groups = {}, -- hl_groups are set by the theme
    },
  },
}
