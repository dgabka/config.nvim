---@module "host"
---@description Host detection utility module

local M = {}

-- Host mappings to environment names
local HOST_MAPPINGS = {
  ["WHM5006336.local"] = "work",
  ["Dawids-MacBook-Pro.local"] = "home",
  ["hyperion"] = "lab",
}

---Get the system hostname using various methods
---@return string hostname The system hostname or empty string if detection fails
function M.get_hostname()
  -- Try a list of commands until one returns a non-empty result
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
        -- Trim leading/trailing whitespace
        return name:match "^%s*(.-)%s*$"
      end
    end
  end

  -- Fallback to the HOSTNAME env var (sometimes unset on macOS)
  local env = os.getenv "HOSTNAME"
  return (env and env:match "%S" and env:match "^%s*(.-)%s*$") or ""
end

---Get the environment name based on hostname
---@return string|nil environment The environment name ("work", "home", "lab") or nil if unknown
function M.get_environment()
  local hostname = M.get_hostname()
  return HOST_MAPPINGS[hostname]
end

---Check if current host matches a specific environment
---@param env string The environment to check ("work", "home", "lab")
---@return boolean matches True if current host matches the environment
function M.is_environment(env)
  return M.get_environment() == env
end

---Check if current host is work environment
---@return boolean is_work True if current host is work environment
function M.is_work()
  return M.is_environment "work"
end

---Check if current host is home environment
---@return boolean is_home True if current host is home environment
function M.is_home()
  return M.is_environment "home"
end

---Check if current host is lab environment
---@return boolean is_lab True if current host is lab environment
function M.is_lab()
  return M.is_environment "lab"
end

return M
