local function copy_to_clipboard(value, label)
  vim.fn.setreg("+", value)
  vim.notify("Copied " .. label .. ": " .. value, vim.log.levels.INFO)
end

local function current_file_path()
  local file_path = vim.api.nvim_buf_get_name(0)

  if file_path == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN)
    return nil
  end

  return file_path
end

vim.api.nvim_create_user_command("CopyFilePathAbsolute", function()
  local file_path = current_file_path()
  if not file_path then
    return
  end

  copy_to_clipboard(file_path, "absolute file path")
end, { desc = "Copy current file path to clipboard" })

vim.api.nvim_create_user_command("CopyFilePath", function()
  local file_path = current_file_path()
  if not file_path then
    return
  end

  local root_marker = vim.fs.find({ ".git" }, { path = file_path, upward = true })[1]
  local root_dir = root_marker and vim.fs.dirname(root_marker) or vim.fn.getcwd()
  local relative_path = vim.fs.relpath(root_dir, file_path) or vim.fn.fnamemodify(file_path, ":.")

  copy_to_clipboard(relative_path, "file path")
end, { desc = "Copy current file path relative to project root" })
