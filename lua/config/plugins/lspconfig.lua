---@module "lazy"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    "b0o/schemastore.nvim",
    "yioneko/nvim-vtsls",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
      callback = function(event)
        local opts = { buffer = event.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Declaration" }))
        vim.keymap.set(
          "n",
          "<leader>ld",
          vim.diagnostic.open_float,
          vim.tbl_extend("force", opts, { desc = "Line diagnostics" })
        )
      end,
    })

    vim.lsp.config("vtsls", {
      settings = {
        typescript = {
          tsserver = {
            experimental = { enableProjectDiagnostics = true },
          },
          inlayHints = {
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
        },
      },
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        local opts = { buffer = bufnr }
        vim.keymap.set(
          "n",
          "<leader>lo",
          "<cmd>VtsExec organize_imports<CR>",
          vim.tbl_extend("force", opts, { desc = "Organize imports" })
        )
        vim.keymap.set(
          "n",
          "<leader>la",
          "<cmd>VtsExec add_missing_imports<CR>",
          vim.tbl_extend("force", opts, { desc = "Add missing imports" })
        )
        vim.keymap.set(
          "n",
          "<leader>lr",
          "<cmd>VtsExec rename_file<CR>",
          vim.tbl_extend("force", opts, { desc = "Rename file" })
        )
      end,
    })

    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    local yaml_schemas = require("schemastore").yaml.schemas()
    yaml_schemas.kubernetes = {
      "k8s/**/*.yaml",
      "k8s/**/*.yml",
      "kubernetes/**/*.yaml",
      "kubernetes/**/*.yml",
      "manifests/**/*.yaml",
      "manifests/**/*.yml",
      "deploy/**/*.yaml",
      "deploy/**/*.yml",
    }
    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          keyOrdering = false,
          schemaStore = { enable = false, url = "" },
          schemas = yaml_schemas,
        },
      },
    })

    vim.lsp.config("nil_ls", {
      settings = {
        ["nil"] = {
          formatting = { command = { "alejandra" } },
        },
      },
    })

    for _, server in ipairs {
      "bashls",
      "cssls",
      "dockerls",
      "eslint",
      "html",
      "jsonls",
      "lua_ls",
      "marksman",
      "nil_ls",
      "vtsls",
      "yamlls",
    } do
      vim.lsp.enable(server)
    end
  end,
}
