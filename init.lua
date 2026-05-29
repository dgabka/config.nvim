if vim.env.NVIM_FULL == "1" then
  require "config"
else
  require "minimal"
end
