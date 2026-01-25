local host = require "config.utils.host"

---@module "lazy"
---@type LazyPluginSpec
return {
  "github/copilot.vim",
  enabled = host.is_work(),
}
