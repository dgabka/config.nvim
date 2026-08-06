local set = vim.keymap.set
local is_inside_work_tree = {}

local function open_files()
  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system "git rev-parse --is-inside-work-tree"
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    MiniPick.builtin.files { tool = "git" }
  else
    MiniPick.builtin.files()
  end
end

local function open_file_explorer()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    MiniFiles.open()
  else
    MiniFiles.open(path, false)
  end
end

set("n", "<leader>-", open_file_explorer, { desc = "Files" })

-- pickers
set("n", "<leader>ff", open_files, { desc = "Git files" })
set("n", "<leader>fr", function()
  MiniExtra.pickers.lsp { scope = "references" }
end, { desc = "References" })
set("n", "<leader>fd", function()
  MiniExtra.pickers.lsp { scope = "definition" }
end, { desc = "Definitions" })
set("n", "<leader>ft", function()
  MiniExtra.pickers.lsp { scope = "type_definition" }
end, { desc = "Type Definitions" })
set("n", "<leader>fg", function()
  MiniPick.builtin.grep_live()
end, { desc = "Grep" })
set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
set("n", "<leader>fb", function()
  MiniPick.builtin.buffers({}, {
    mappings = {
      delete_buf = {
        char = "<C-d>",
        func = function()
          local item = MiniPick.get_picker_matches().current
          if item then
            vim.api.nvim_buf_delete(item.bufnr, { force = false })
            -- ponytail: restart picker to refresh list after deletion
            MiniPick.set_picker_items(vim.tbl_filter(function(b)
              return vim.api.nvim_buf_is_valid(b.bufnr)
            end, MiniPick.get_picker_items()))
          end
        end,
      },
    },
  })
end, { desc = "Buffers" })
set("n", "<leader>fh", function()
  MiniPick.builtin.help()
end, { desc = "Help tags" })
set("n", "<leader>fo", function()
  MiniExtra.pickers.oldfiles()
end, { desc = "Recent files" })
set("n", "<leader>fw", function()
  MiniPick.builtin.grep { pattern = vim.fn.expand "<cword>" }
end, { desc = "Word under cursor" })
set("n", "<leader>f/", function()
  MiniExtra.pickers.buf_lines { scope = "current" }
end, { desc = "Search current buffer" })
set("n", "<leader>fD", function()
  MiniExtra.pickers.diagnostic { scope = "all" }
end, { desc = "Workspace Diagnostics" })

-- git hunks
set("n", "]c", function()
  MiniDiff.goto_hunk "next"
end, { desc = "Next hunk" })
set("n", "[c", function()
  MiniDiff.goto_hunk "prev"
end, { desc = "Previous hunk" })

local function hunk(action)
  local line = vim.fn.line "."
  MiniDiff.do_hunks(0, action, { line_start = line, line_end = line })
end

set("n", "<leader>hs", function()
  hunk "apply"
end, { desc = "Stage hunk" })
set("n", "<leader>hr", function()
  hunk "reset"
end, { desc = "Reset hunk" })
set("n", "<leader>hp", MiniDiff.toggle_overlay, { desc = "Toggle hunk preview" })
set("n", "<leader>hb", function()
  local line = vim.fn.line "."
  vim.cmd(("Git blame -L %d,%d -- %%"):format(line, line))
end, { desc = "Blame line" })

-- quickfix list
set("n", "<leader>co", ":copen<CR>", { desc = "Open" })
set("n", "<leader>cn", ":cnext<CR>", { desc = "Next" })
set("n", "<leader>cp", ":cprev<CR>", { desc = "Prev" })
set("n", "<leader>cc", ":cclose<CR>", { desc = "Close" })

-- replace paste without overwriting register
set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- yank to system clipboard
set("v", "<leader>y", [["+y]], { desc = "Yank to clipboard" })
set("n", "<leader>y", [["+Y]], { desc = "Yank line to clipboard" })

-- toggle inlay_hints
set("n", "<leader>ti", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- toggle line wrap
set("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })

-- These mappings control the size of splits (height/width)
set("n", "<M-,>", "<c-w>5<")
set("n", "<M-.>", "<c-w>5>")
set("n", "<M-t>", "<C-W>+")
set("n", "<M-s>", "<C-W>-")

-- Disable hlsearch if it's on, otherwise just do "enter"
set("n", "<CR>", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.v.hlsearch == 1 then
    vim.cmd.nohl()
    return ""
  else
    return vim.keycode "<CR>"
  end
end, { expr = true })

set("n", "<leader>dl", ":%diffget _LOCAL_<CR>", { desc = "Pick local changes" })
set("n", "<leader>dr", ":%diffget _REMOTE_<CR>", { desc = "Pick changes from remote" })

set("n", "<leader>u", function()
  vim.cmd.packadd "nvim.undotree"
  require("undotree").open()
end, { desc = "Toggle Undotree" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result cursor centered" })
