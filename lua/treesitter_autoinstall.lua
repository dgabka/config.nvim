local M = {}

local installs = {}
local available = nil

local function get_lang(buf)
  return vim.treesitter.language.get_lang(vim.bo[buf].filetype)
end

local function can_install(treesitter, lang)
  if not available then
    available = {}

    for _, parser in ipairs(treesitter.get_available()) do
      available[parser] = true
    end
  end

  return available[lang] == true
end

local function enable(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return true
  end

  local parser_loaded = vim.treesitter.language.add(lang)
  if not parser_loaded then
    return false
  end

  local ok = pcall(vim.treesitter.start, buf, lang)
  if not ok then
    return false
  end

  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  return true
end

local function start_after_install(lang)
  local install = installs[lang]
  installs[lang] = nil

  if not install or not install.ok then
    return
  end

  for buf in pairs(install.buffers) do
    if vim.api.nvim_buf_is_valid(buf) and get_lang(buf) == lang then
      enable(buf, lang)
    end
  end
end

local function install_for_buffer(treesitter, buf, lang)
  if installs[lang] then
    installs[lang].buffers[buf] = true
    return
  end

  installs[lang] = {
    buffers = {
      [buf] = true,
    },
  }

  local ok, task = pcall(treesitter.install, { lang })
  if not ok or not task then
    installs[lang] = nil
    return
  end

  installs[lang].task = task
  task:await(function(err, installed)
    local install = installs[lang]
    if install then
      install.ok = not err and installed
    end

    vim.schedule(function()
      start_after_install(lang)
    end)
  end)
end

function M.setup(opts)
  local treesitter = require "nvim-treesitter"
  local group = vim.api.nvim_create_augroup(opts.group, { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      local lang = get_lang(args.buf)
      if not lang then
        return
      end

      if enable(args.buf, lang) or not can_install(treesitter, lang) then
        return
      end

      install_for_buffer(treesitter, args.buf, lang)
    end,
  })
end

return M
