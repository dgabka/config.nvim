local M = {}

local uv = vim.uv or vim.loop

local spinner_symbols = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}
local spinner_len = #spinner_symbols

local state = {
  processing = false,
  spinner_index = 0,
  timer = nil,
}

local function refresh_lualine()
  local ok, lualine = pcall(require, "lualine")
  if ok then
    lualine.refresh { place = { "statusline" } }
  end
end

local function start_timer()
  if state.timer then
    return
  end
  state.timer = uv.new_timer()
  state.timer:start(0, 100, vim.schedule_wrap(refresh_lualine))
end

local function stop_timer()
  if not state.timer then
    return
  end
  state.timer:stop()
  state.timer:close()
  state.timer = nil
end

local function ensure_autocmds()
  if M._autocmds_set then
    return
  end
  M._autocmds_set = true

  local group = vim.api.nvim_create_augroup("CodeCompanionHooksLualine", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(args)
      if args.match == "CodeCompanionRequestStarted" then
        state.processing = true
        start_timer()
      elseif args.match == "CodeCompanionRequestFinished" then
        state.processing = false
        state.spinner_index = 0
        stop_timer()
        refresh_lualine()
      end
    end,
  })
end

function M.status()
  ensure_autocmds()
  if not state.processing then
    return ""
  end
  state.spinner_index = (state.spinner_index % spinner_len) + 1
  return spinner_symbols[state.spinner_index]
end

return M
