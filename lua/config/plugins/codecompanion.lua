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
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle chat" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Actions" },
    { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to chat" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = "v", desc = "Inline prompt" },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)

    local handle
    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeCompanionRequest*",
      callback = function(args)
        if args.match == "CodeCompanionRequestStarted" then
          handle = require("fidget.progress.handle").create {
            title = "CodeCompanion",
            lsp_client = { name = "codecompanion" },
          }
        elseif args.match == "CodeCompanionRequestFinished" then
          if handle then
            handle:finish()
            handle = nil
          end
        end
      end,
    })
  end,
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
