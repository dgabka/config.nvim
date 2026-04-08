local M = {}

local EMOJI_MARKERS = {
  due = "📅",
  created = "➕",
  done = "✅",
}

local DEFAULTS = {
  command_name = "Tasks",
  vault_root = function()
    local dir = os.getenv "OBSIDIAN_VAULT"
    if not dir or dir == "" then
      return nil
    end

    return dir
  end,
  filetype = "markdown",
  metadata_format = "dataview",
  statuses = {
    todo = " ",
    progress = "/",
    done = "x",
    cancelled = "-",
  },
  status_order = { "todo", "progress", "done", "cancelled" },
  priorities = { "highest", "high", "low", "lowest" },
  priority_markers = {
    highest = "⏫",
    high = "🔼",
    low = "🔽",
    lowest = "⏬",
  },
  priority_values = {
    highest = "highest",
    high = "high",
    low = "low",
    lowest = "lowest",
  },
  priority_aliases = {
    highest = "highest",
    high = "high",
    low = "low",
    lowest = "lowest",
  },
  dataview_field_order = { "priority", "repeat", "created", "start", "scheduled", "due", "cancelled", "completion" },
  review_modes = { "open", "today", "file" },
  priority_actions = { "cycle", "clear" },
  due_choices = { "today", "tomorrow", "clear" },
  exclude_globs = { ".obsidian/**", "templates/**" },
  done_heading = "## Done",
  done_heading_pattern = "^## Done%s*$",
  notify_prefix = "Tasks: ",
}

local COMMANDS = { "new", "toggle", "status", "priority", "due", "review", "move_done", "move_done_all" }

local state = {
  did_setup = false,
  opts = nil,
}

local function trim(value)
  return vim.trim(value or "")
end

local function trim_trailing_whitespace(value)
  return (value or ""):gsub("%s+$", "")
end

local function nil_if_empty(value)
  local normalized = trim(value)
  if normalized == "" then
    return nil
  end

  return normalized
end

local function current_date()
  return os.date "%Y-%m-%d"
end

local function tomorrow_date()
  local today = os.date "*t"
  today.hour = 0
  today.min = 0
  today.sec = 0
  today.day = today.day + 1
  return os.date("%Y-%m-%d", os.time(today))
end

local function is_valid_date(value)
  return type(value) == "string" and value:match "^%d%d%d%d%-%d%d%-%d%d$" ~= nil
end

local function normalize_opts(opts)
  local merged = vim.tbl_deep_extend("force", {}, DEFAULTS, opts or {})
  merged.priority_rank = {}
  merged.marker_to_priority = {}
  merged.priority_to_marker = {}
  merged.priority_to_value = {}

  for index, priority in ipairs(merged.priorities) do
    merged.priority_rank[priority] = index
  end

  for priority, marker in pairs(merged.priority_markers or {}) do
    merged.marker_to_priority[marker] = priority
    merged.priority_to_marker[priority] = marker
  end

  for priority, value in pairs(merged.priority_values or {}) do
    merged.priority_to_value[priority] = value
  end

  merged.command_args = {
    status = merged.status_order,
    priority = vim.list_extend(vim.deepcopy(merged.priorities), merged.priority_actions),
    due = merged.due_choices,
    review = merged.review_modes,
  }

  return merged
end

local function get_opts()
  return state.opts or normalize_opts()
end

local function notify(message, level)
  local opts = get_opts()
  vim.notify((opts.notify_prefix or "") .. message, level or vim.log.levels.INFO)
end

local function resolve_vault_root()
  local root = get_opts().vault_root
  if type(root) == "function" then
    root = root()
  end

  if not root or root == "" then
    return nil
  end

  return vim.fs.normalize(vim.fn.expand(root))
end

local function path_in_vault(path)
  local root = resolve_vault_root()
  if not root or not path or path == "" then
    return false
  end

  local normalized = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  return normalized == root or vim.startswith(normalized, root .. "/")
end

local function normalize_priority(value)
  if type(value) ~= "string" then
    return nil
  end

  local normalized = trim(value)
  if normalized == "" then
    return nil
  end

  local opts = get_opts()
  if opts.marker_to_priority[normalized] then
    return opts.marker_to_priority[normalized]
  end

  return opts.priority_aliases[normalized:lower()]
end

local function priority_marker(priority)
  return get_opts().priority_to_marker[priority]
end

local function priority_value(priority)
  return get_opts().priority_to_value[priority] or priority
end

local function take_date_marker(value, marker)
  local pattern = "^(.-)%s*" .. vim.pesc(marker) .. "%s*(%d%d%d%d%-%d%d%-%d%d)$"
  local before, date = value:match(pattern)
  if not before then
    return nil
  end

  return trim_trailing_whitespace(before), date
end

local function take_priority_marker(value)
  for _, priority in ipairs(get_opts().priorities) do
    local marker = priority_marker(priority)
    if marker and vim.endswith(value, marker) then
      local before = value:sub(1, #value - #marker)
      return trim_trailing_whitespace(before), priority
    end
  end

  return nil
end

local function take_dataview_field(value)
  local bracket_index, key, field_value = value:match "^.*()%[([%w_-]+)::%s*(.-)%]%s*$"
  if not bracket_index then
    return nil
  end

  if bracket_index > 1 and not value:sub(bracket_index - 1, bracket_index - 1):match "%s" then
    return nil
  end

  local before = trim_trailing_whitespace(value:sub(1, bracket_index - 1))
  return before, key:lower(), trim(field_value)
end

local function parse_dataview_fields(value)
  local remaining = trim_trailing_whitespace(value)
  local fields = {}
  local order = {}

  while true do
    local before, key, field_value = take_dataview_field(remaining)
    if not key then
      break
    end

    fields[key] = field_value
    table.insert(order, 1, key)
    remaining = before
  end

  return remaining, fields, order
end

local function sync_task_from_dataview_fields(task)
  task.priority = normalize_priority(task.fields.priority)
  task.due = nil_if_empty(task.fields.due)
  task.created = nil_if_empty(task.fields.created)
  task.done = nil_if_empty(task.fields.completion)
  task.cancelled = nil_if_empty(task.fields.cancelled)
end

local function build_dataview_fields(task)
  local fields = vim.deepcopy(task.fields or {})

  if task.priority then
    fields.priority = priority_value(task.priority)
  else
    fields.priority = nil
  end

  if task.due then
    fields.due = task.due
  else
    fields.due = nil
  end

  if task.created then
    fields.created = task.created
  else
    fields.created = nil
  end

  if task.done then
    fields.completion = task.done
  else
    fields.completion = nil
  end

  if task.cancelled then
    fields.cancelled = task.cancelled
  else
    fields.cancelled = nil
  end

  return fields
end

local function dataview_field_order(task, fields)
  local order = {}
  local seen = {}

  for _, key in ipairs(task.field_order or {}) do
    if not seen[key] and trim(fields[key]) ~= "" then
      table.insert(order, key)
      seen[key] = true
    end
  end

  for _, key in ipairs(get_opts().dataview_field_order) do
    if not seen[key] and trim(fields[key]) ~= "" then
      table.insert(order, key)
      seen[key] = true
    end
  end

  local extras = vim.tbl_keys(fields)
  table.sort(extras)
  for _, key in ipairs(extras) do
    if not seen[key] and trim(fields[key]) ~= "" then
      table.insert(order, key)
    end
  end

  return order
end

---@param line string
---@return table|nil
function M.parse_task_line(line)
  if type(line) ~= "string" then
    return nil
  end

  local indent, status, remainder = line:match "^(%s*)-%s%[([ x/%-])%]%s?(.*)$"
  if not indent then
    return nil
  end

  local description, fields, field_order = parse_dataview_fields(remainder)
  local task = {
    indent = indent,
    status = status,
    description = trim_trailing_whitespace(description),
    priority = nil,
    due = nil,
    created = nil,
    done = nil,
    cancelled = nil,
    format = next(fields) and "dataview" or get_opts().metadata_format,
    fields = fields,
    field_order = field_order,
  }

  sync_task_from_dataview_fields(task)

  local saw_emoji_metadata = false
  local changed = true
  while changed do
    changed = false

    local before, value = take_date_marker(task.description, EMOJI_MARKERS.done)
    if value then
      task.description = before
      if not task.done or task.done == "" then
        task.done = value
      end
      saw_emoji_metadata = true
      changed = true
    end

    before, value = take_date_marker(task.description, EMOJI_MARKERS.created)
    if value then
      task.description = before
      if not task.created or task.created == "" then
        task.created = value
      end
      saw_emoji_metadata = true
      changed = true
    end

    before, value = take_date_marker(task.description, EMOJI_MARKERS.due)
    if value then
      task.description = before
      if not task.due or task.due == "" then
        task.due = value
      end
      saw_emoji_metadata = true
      changed = true
    end

    before, value = take_priority_marker(task.description)
    if value then
      task.description = before
      if not task.priority then
        task.priority = value
      end
      saw_emoji_metadata = true
      changed = true
    end
  end

  if next(fields) then
    task.format = "dataview"
  elseif saw_emoji_metadata then
    task.format = "emoji"
  end

  task.description = trim(task.description)
  return task
end

local function serialize_emoji_task_line(task)
  local parts = {}
  local description = trim(task.description)

  if description ~= "" then
    table.insert(parts, description)
  end

  local marker = priority_marker(task.priority)
  if marker then
    table.insert(parts, marker)
  end

  if task.due then
    table.insert(parts, EMOJI_MARKERS.due .. " " .. task.due)
  end

  if task.created then
    table.insert(parts, EMOJI_MARKERS.created .. " " .. task.created)
  end

  if task.done then
    table.insert(parts, EMOJI_MARKERS.done .. " " .. task.done)
  end

  local suffix = table.concat(parts, " ")
  return string.format("%s- [%s]%s%s", task.indent or "", task.status or " ", suffix ~= "" and " " or "", suffix)
end

local function serialize_dataview_task_line(task)
  local fields = build_dataview_fields(task)
  local suffix_parts = {}
  for _, key in ipairs(dataview_field_order(task, fields)) do
    table.insert(suffix_parts, string.format("[%s:: %s]", key, fields[key]))
  end

  local description = trim(task.description)
  local suffix = description
  if not vim.tbl_isempty(suffix_parts) then
    local field_suffix = table.concat(suffix_parts, "  ")
    if suffix ~= "" then
      suffix = suffix .. "  " .. field_suffix
    else
      suffix = field_suffix
    end
  end

  return string.format("%s- [%s]%s%s", task.indent or "", task.status or " ", suffix ~= "" and " " or "", suffix)
end

---@param task table
---@return string
function M.serialize_task_line(task)
  if (task.format or get_opts().metadata_format) == "emoji" then
    return serialize_emoji_task_line(task)
  end

  return serialize_dataview_task_line(task)
end

local function is_markdown_buffer(bufnr)
  return vim.bo[bufnr].filetype == get_opts().filetype
end

local function current_buffer_path(bufnr)
  return vim.api.nvim_buf_get_name(bufnr)
end

local function current_buffer_is_task_buffer()
  local bufnr = vim.api.nvim_get_current_buf()

  if not is_markdown_buffer(bufnr) then
    notify("current buffer is not markdown", vim.log.levels.WARN)
    return false
  end

  if not path_in_vault(current_buffer_path(bufnr)) then
    notify("current buffer is outside the Obsidian vault", vim.log.levels.WARN)
    return false
  end

  return true
end

local function get_task_context()
  if not current_buffer_is_task_buffer() then
    return nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  local task = M.parse_task_line(line)
  if not task then
    notify("current line is not a task", vim.log.levels.WARN)
    return nil
  end

  return {
    bufnr = bufnr,
    row = row,
    line = line,
    task = task,
  }
end

local function write_task_line(bufnr, row, task)
  vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { M.serialize_task_line(task) })
end

local function task_is_open(task)
  local statuses = get_opts().statuses
  return task.status == statuses.todo or task.status == statuses.progress
end

local function set_status(task, status_name)
  local symbol = get_opts().statuses[status_name]
  if not symbol then
    return false
  end

  task.status = symbol
  if status_name == "done" then
    task.done = current_date()
    task.cancelled = nil
  elseif status_name == "cancelled" then
    task.cancelled = current_date()
    task.done = nil
  else
    task.done = nil
    task.cancelled = nil
  end

  return true
end

local function cycle_priority(task)
  local opts = get_opts()
  if not task.priority then
    task.priority = opts.priorities[1]
    return
  end

  local current_rank = opts.priority_rank[task.priority]
  task.priority = opts.priorities[(current_rank or 0) + 1]
end

local function find_done_heading(lines)
  local pattern = get_opts().done_heading_pattern
  for index, line in ipairs(lines) do
    if line:match(pattern) then
      return index
    end
  end

  return nil
end

local function move_to_done()
  local context = get_task_context()
  if not context then
    return
  end

  if context.task.status ~= get_opts().statuses.done then
    notify("current task is not done", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(context.bufnr, 0, -1, false)
  local done_row = find_done_heading(lines)
  if not done_row then
    notify("no '" .. get_opts().done_heading .. "' section found", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_lines(context.bufnr, context.row, context.row + 1, false, {})
  if done_row > context.row + 1 then
    done_row = done_row - 1
  end
  vim.api.nvim_buf_set_lines(context.bufnr, done_row, done_row, false, { context.line })
end

local function move_all_to_done()
  if not current_buffer_is_task_buffer() then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local done_row = find_done_heading(lines)
  if not done_row then
    notify("no '" .. get_opts().done_heading .. "' section found", vim.log.levels.WARN)
    return
  end

  local checked = {}
  local remaining = {}
  for index, line in ipairs(lines) do
    local task = M.parse_task_line(line)
    if task and task.status == get_opts().statuses.done and index < done_row then
      table.insert(checked, line)
    else
      table.insert(remaining, line)
    end
  end

  if vim.tbl_isempty(checked) then
    notify("no done tasks above '" .. get_opts().done_heading .. "'", vim.log.levels.INFO)
    return
  end

  local result = {}
  for _, line in ipairs(remaining) do
    table.insert(result, line)
    if line:match(get_opts().done_heading_pattern) then
      for _, checked_line in ipairs(checked) do
        table.insert(result, checked_line)
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

local function prompt_status(callback)
  vim.ui.select(get_opts().status_order, { prompt = "Task status:" }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

local function prompt_priority(callback)
  local choices = vim.deepcopy(get_opts().priorities)
  table.insert(choices, "clear")

  vim.ui.select(choices, { prompt = "Task priority:" }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

local function prompt_due(callback)
  vim.ui.input({ prompt = "Due date (today, tomorrow, clear, YYYY-MM-DD): " }, function(input)
    if input and input ~= "" then
      callback(trim(input))
    end
  end)
end

local function prompt_review(callback)
  vim.ui.select(get_opts().review_modes, { prompt = "Task review:" }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

local function with_current_task(mutator)
  local context = get_task_context()
  if not context then
    return
  end

  local did_change = mutator(context.task)
  if did_change == false then
    return
  end

  write_task_line(context.bufnr, context.row, context.task)
end

local function command_toggle()
  with_current_task(function(task)
    if task.status == get_opts().statuses.done then
      return set_status(task, "todo")
    end

    return set_status(task, "done")
  end)
end

local function command_status(target)
  if not target then
    prompt_status(command_status)
    return
  end

  with_current_task(function(task)
    if not set_status(task, target) then
      notify("unsupported status: " .. target, vim.log.levels.ERROR)
      return false
    end
  end)
end

local function command_priority(action)
  if not action then
    prompt_priority(command_priority)
    return
  end

  with_current_task(function(task)
    if action == "clear" then
      task.priority = nil
      return
    end

    if action == "cycle" then
      cycle_priority(task)
      return
    end

    if not get_opts().priority_rank[action] then
      notify("unsupported priority action: " .. action, vim.log.levels.ERROR)
      return false
    end

    task.priority = action
  end)
end

local function resolve_due_value(value)
  if value == "clear" then
    return nil
  end
  if value == "today" then
    return current_date()
  end
  if value == "tomorrow" then
    return tomorrow_date()
  end
  if is_valid_date(value) then
    return value
  end

  return false
end

local function command_due(value)
  if not value then
    prompt_due(command_due)
    return
  end

  local resolved = resolve_due_value(value)
  if resolved == false then
    notify("expected today, tomorrow, clear, or YYYY-MM-DD", vim.log.levels.ERROR)
    return
  end

  with_current_task(function(task)
    task.due = resolved
  end)
end

local function task_sort_key(task)
  local opts = get_opts()
  local due = is_valid_date(task.due) and task.due or "9999-99-99"
  return due, opts.priority_rank[task.priority] or 99
end

local function open_review(items, title)
  if vim.tbl_isempty(items) then
    notify("no tasks found", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, "r", {
    title = title,
    items = items,
  })
  vim.cmd.copen()
  vim.cmd.cfirst()
end

local function relative_path(path)
  local root = resolve_vault_root()
  if not root then
    return path
  end

  return path:gsub("^" .. vim.pesc(root) .. "/?", "")
end

local function quickfix_item(path, lnum, col, line, task)
  local text = M.serialize_task_line(task)
  return {
    filename = path,
    lnum = lnum,
    col = col,
    text = string.format("%s :: %s", relative_path(path), text),
    user_data = {
      task = task,
      line = line,
    },
  }
end

local function sort_review_items(items)
  table.sort(items, function(left, right)
    local left_due, left_priority = task_sort_key(left.user_data.task)
    local right_due, right_priority = task_sort_key(right.user_data.task)

    if left_due ~= right_due then
      return left_due < right_due
    end

    if left_priority ~= right_priority then
      return left_priority < right_priority
    end

    if left.filename ~= right.filename then
      return left.filename < right.filename
    end

    return left.lnum < right.lnum
  end)
end

local function collect_vault_tasks()
  local root = resolve_vault_root()
  if not root then
    notify "vault root is not configured"
    return {}
  end

  local command = {
    "rg",
    "--vimgrep",
    "--color=never",
    "--glob",
    "*.md",
  }

  for _, glob in ipairs(get_opts().exclude_globs) do
    table.insert(command, "--glob")
    table.insert(command, "!" .. glob)
  end

  table.insert(command, "^\\s*-\\s+\\[[ x/\\-]\\]")
  table.insert(command, root)

  local result = vim.system(command, { text = true }):wait()
  if result.code > 1 then
    notify(trim(result.stderr), vim.log.levels.ERROR)
    return {}
  end

  local items = {}
  for entry in (result.stdout or ""):gmatch "[^\r\n]+" do
    local path, lnum, col, line = entry:match "^(.-):(%d+):(%d+):(.*)$"
    if path and line then
      local task = M.parse_task_line(line)
      if task then
        table.insert(items, quickfix_item(path, tonumber(lnum), tonumber(col), line, task))
      end
    end
  end

  return items
end

local function collect_file_tasks()
  if not current_buffer_is_task_buffer() then
    return {}
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local path = current_buffer_path(bufnr)
  local items = {}

  for index, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local task = M.parse_task_line(line)
    if task and task_is_open(task) then
      table.insert(items, quickfix_item(path, index, 1, line, task))
    end
  end

  return items
end

local function command_review(mode)
  if not mode then
    prompt_review(command_review)
    return
  end

  if mode == "file" then
    open_review(collect_file_tasks(), get_opts().command_name .. ": file")
    return
  end

  local today = current_date()
  local items = {}
  for _, item in ipairs(collect_vault_tasks()) do
    local task = item.user_data.task
    if mode == "open" and task_is_open(task) then
      table.insert(items, item)
    elseif mode == "today" and task_is_open(task) and is_valid_date(task.due) and task.due <= today then
      table.insert(items, item)
    end
  end

  if mode ~= "open" and mode ~= "today" then
    notify("unsupported review mode: " .. mode, vim.log.levels.ERROR)
    return
  end

  sort_review_items(items)
  open_review(items, get_opts().command_name .. ": " .. mode)
end

local function command_new(description)
  if not current_buffer_is_task_buffer() then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""
  local indent = current_line:match "^(%s*)" or ""
  local text = trim(description)
  local task = {
    indent = indent,
    status = get_opts().statuses.todo,
    description = text,
    created = current_date(),
    format = get_opts().metadata_format,
    fields = {},
    field_order = {},
  }

  local line = M.serialize_task_line(task)
  local cursor_col = #indent + 6 + #text
  vim.api.nvim_buf_set_lines(bufnr, cursor[1], cursor[1], false, { line })
  vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor_col })
end

local function run_command(args)
  local subcommand = args[1]
  if not subcommand then
    vim.ui.select(COMMANDS, { prompt = get_opts().command_name .. ":" }, function(choice)
      if choice then
        run_command { choice }
      end
    end)
    return
  end

  if subcommand == "new" then
    return command_new(table.concat(vim.list_slice(args, 2), " "))
  end
  if subcommand == "toggle" then
    return command_toggle()
  end
  if subcommand == "status" then
    return command_status(args[2])
  end
  if subcommand == "priority" then
    return command_priority(args[2])
  end
  if subcommand == "due" then
    return command_due(args[2])
  end
  if subcommand == "review" then
    return command_review(args[2])
  end
  if subcommand == "move_done" then
    return move_to_done()
  end
  if subcommand == "move_done_all" then
    return move_all_to_done()
  end

  notify("unknown subcommand: " .. subcommand, vim.log.levels.ERROR)
end

local function filter_choices(choices, arglead)
  return vim.tbl_filter(function(choice)
    return choice:find("^" .. vim.pesc(arglead))
  end, choices)
end

local function tasks_complete(arglead, cmdline)
  local tokens = vim.split(cmdline, "%s+", { trimempty = true })
  if #tokens <= 1 then
    return filter_choices(COMMANDS, arglead)
  end

  local subcommand = tokens[2]
  if #tokens == 2 and not vim.endswith(cmdline, " ") then
    return filter_choices(COMMANDS, arglead)
  end

  return filter_choices(get_opts().command_args[subcommand] or {}, arglead)
end

function M.setup(opts)
  if state.did_setup then
    return
  end

  state.opts = normalize_opts(opts)
  state.did_setup = true

  if not resolve_vault_root() then
    return
  end

  vim.api.nvim_create_user_command(get_opts().command_name, function(data)
    run_command(data.fargs)
  end, {
    nargs = "*",
    complete = tasks_complete,
  })
end

return M
