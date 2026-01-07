local function get_hostname()
  -- try a list of commands until one returns a non-empty result
  local cmds = {
    "hostname",
    "uname -n",
    "scutil --get HostName",
    "scutil --get LocalHostName",
  }

  for _, cmd in ipairs(cmds) do
    local fh = io.popen(cmd .. " 2>/dev/null")
    if fh then
      local name = fh:read "*l"
      fh:close()
      if name and name:match "%S" then
        -- trim leading/trailing whitespace
        return name:match "^%s*(.-)%s*$"
      end
    end
  end

  -- fallback to the HOSTNAME env var (sometimes unset on macOS)
  local env = os.getenv "HOSTNAME"
  return (env and env:match "%S" and env:match "^%s*(.-)%s*$") or ""
end

local function get_adapters()
  local hostname = get_hostname()

  local use_copilot = (hostname == "WHM5006336.local")
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
              api_key = "cmd:printf '%s' \"$(pass show anthropic/api)\"",
            },
          })
        end,
      },
    },
  },
}
