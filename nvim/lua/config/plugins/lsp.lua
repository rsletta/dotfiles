return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      }
    },
    config = function()
      -- Set up completion options
      vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

      -- Auto-set omnifunc for LSP completion
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.offsetEncoding = { "utf-8" }

      require("lspconfig").lua_ls.setup { capabilities = capabilities }
      require("lspconfig").yamlls.setup { capabilities = capabilities }
      require'lspconfig'.helm_ls.setup{
        capabilities = capabilities,
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = 'yaml-language-server',
            }
          }
        }
      }
      require("lspconfig").dockerls.setup { capabilities = capabilities }
      require'lspconfig'.docker_compose_language_service.setup{ capabilities = capabilities }
      require'lspconfig'.marksman.setup{ capabilities = capabilities }
      require("lspconfig").basedpyright.setup { capabilities = capabilities }
      require("lspconfig").svelte.setup { capabilities = capabilities }
      require("lspconfig").tailwindcss.setup { capabilities = capabilities }
      require("lspconfig").vtsls.setup { capabilities = capabilities }
      require("lspconfig").jsonls.setup { capabilities = capabilities }
      require("lspconfig").cssls.setup { capabilities = capabilities }
      require("lspconfig").html.setup { capabilities = capabilities }
      require("lspconfig").taplo.setup { capabilities = capabilities }

      local wk = require("which-key")
      wk.add({
        { "K", vim.lsp.buf.hover, desc = "LSP hover" },
        { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
        { "gr", vim.lsp.buf.references, desc = "Show references" },
        { "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
        { "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
        { "<leader>e", vim.diagnostic.open_float, desc = "Show diagnostic" },
      })
    end,
  }
}
