if vim.env.NVIM_MINI == "1" then
  require "config-mini"
else
  require "config"
end
