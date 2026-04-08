local vault_root = os.getenv "OBSIDIAN_VAULT"

---@module "lazy"
---@type LazySpec
return {
  dir = vim.fn.stdpath "config" .. "/local-plugins/obsidian-tasks.nvim",
  name = "obsidian-tasks.nvim",
  main = "obsidian_tasks",
  enabled = vault_root ~= nil and vault_root ~= "",
  ft = "markdown",
  cmd = "Tasks",
  keys = {
    { "<leader>mr", "<cmd>Tasks review open<cr>", desc = "Review open tasks" },
    { "<leader>mn", "<cmd>Tasks new<cr>", desc = "New task", ft = "markdown" },
    { "<leader>mx", "<cmd>Tasks toggle<cr>", desc = "Toggle task", ft = "markdown" },
    { "<leader>ms", "<cmd>Tasks status<cr>", desc = "Set task status", ft = "markdown" },
    { "<leader>mp", "<cmd>Tasks priority<cr>", desc = "Set task priority", ft = "markdown" },
    { "<leader>mP", "<cmd>Tasks priority cycle<cr>", desc = "Cycle task priority", ft = "markdown" },
    { "<leader>mu", "<cmd>Tasks due<cr>", desc = "Set task due date", ft = "markdown" },
    { "<leader>md", "<cmd>Tasks move_done<cr>", desc = "Move done task to Done", ft = "markdown" },
    { "<leader>mD", "<cmd>Tasks move_done_all<cr>", desc = "Move all done tasks to Done", ft = "markdown" },
  },
  opts = {
    vault_root = function()
      return os.getenv "OBSIDIAN_VAULT"
    end,
    metadata_format = "dataview",
    exclude_globs = { ".obsidian/**", "templates/**" },
    done_heading = "## Done",
    done_heading_pattern = "^## Done%s*$",
  },
}
