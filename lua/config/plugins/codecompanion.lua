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
    prompt_library = {
      markdown = {
        dirs = {
          vim.fn.getcwd() .. "/.prompts", -- Can be relative
        },
      },
    },
    strategies = get_adapters(),
    adapters = {
      acp = {
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
            },
          })
        end,
      },
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            name = "claude",
            env = {
              api_key = "cmd:printf '%s' \"$(pass show anthropic/api-key)\"",
            },
          })
        end,
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            env = {
              url = "http://192.168.70.3:11434",
              model_for_url = "schema.model.default",
            },
            schema = {
              model = { default = "glm-4.7-flash" },
            },

            headers = {
              ["Content-Type"] = "application/json",
            },
          })
        end,
      },
    },
  },
}
