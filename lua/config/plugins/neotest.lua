---@module "lazy"
---@type LazySpec
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest",
  },

  keys = {
    {
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      desc = "Run test file",
    },
    {
      "<leader>ta",
      function()
        require("neotest").run.run(vim.fn.getcwd())
      end,
      desc = "Run test suite",
    },
    {
      "<leader>tl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Run last test",
    },
  },

  config = function()
    local neotest = require "neotest"

    neotest.setup {
      adapters = {
        require "neotest-vitest",
        require "rustaceanvim.neotest",
      },
    }

    vim.keymap.set("n", "<leader>ts", function()
      neotest.summary.toggle()
    end, { desc = "Toggle test summary" })
    vim.keymap.set("n", "<leader>to", function()
      neotest.output.open { enter = true }
    end, { desc = "Show test output" })
    vim.keymap.set("n", "<leader>tx", function()
      neotest.run.stop()
    end, { desc = "Stop test run" })
  end,
}
