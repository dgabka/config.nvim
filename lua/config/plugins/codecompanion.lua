local host_utils = require "config.utils.host"

local function get_adapters()
  -- Use copilot adapter for work environment, anthropic for others
  local use_copilot = host_utils.is_work()
  local adapter = use_copilot and "copilot" or "anthropic"

  return {
    chat = { adapter = adapter },
    inline = { adapter = adapter },
    cmd = { adapter = adapter },
  }
end

local fmt = string.format

---@module "lazy"
---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanionChat", "CodeCompanionActions", "CodeCompanion" },
  opts = {
    strategies = get_adapters(),
    adapters = {
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            name = "claude",
            env = {
              api_key = "cmd:printf '%s' \"$(pass show anthropic/api-key)\"",
            },
          })
        end,
      },
    },
  },
}
