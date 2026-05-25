---@module "str_utils"
---@description Host detection utility module

local M = {}

---Slugify a string
---@param str string The input string to slugify
---@return string str_slug The slugified string
function M.slugify(str)
  local str_slug = str
    :lower()
    :gsub("[^%w%s-]", "") -- Remove special characters except spaces and hyphens
    :gsub("%s+", "-") -- Replace spaces with hyphens
    :gsub("-+", "-") -- Replace multiple hyphens with single hyphen
    :gsub("^-+", "") -- Remove leading hyphens
    :gsub("-+$", "") -- Remove trailing hyphens
  return str_slug
end

return M
