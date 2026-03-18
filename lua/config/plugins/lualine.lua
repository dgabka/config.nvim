local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local function obsession_status()
  if vim.fn.exists("*ObsessionStatus") == 0 then
    return ""
  end

  return vim.fn.ObsessionStatus()
end

---@module "lazy"
---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "sageveil",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = { { "filename", path = 1 }, { "diff", colored = true, source = diff_source } },
      lualine_x = {
        "diagnostics",
      },
      lualine_y = { "filetype", "location" },
      lualine_z = { obsession_status },
    },
    extensions = { "fugitive", "nvim-dap-ui", "oil", "trouble" },
  },
}
