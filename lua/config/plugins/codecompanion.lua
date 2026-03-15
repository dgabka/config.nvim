local host_utils = require "config.utils.host"

local function get_adapters()
  local adapter = host_utils.is_work() and "codex" or "claude_code"

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
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = "cmd:printf '%s' \"$(pass show anthropic/claude-code-token)\"",
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
      },
    },
  },
}
