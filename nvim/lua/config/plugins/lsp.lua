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

      -- List of LSP servers with default config
      local servers = {
        'lua_ls',
        'yamlls',
        'dockerls',
        'docker_compose_language_service',
        'marksman',
        'basedpyright',
        'svelte',
        'tailwindcss',
        'vtsls',
        'jsonls',
        'cssls',
        'html',
        'taplo',
        'gopls',
        'terraformls',
      }

      -- Configure and enable each server
      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
        vim.lsp.enable(server)
      end

      -- helm_ls needs custom settings
      vim.lsp.config('helm_ls', {
        capabilities = capabilities,
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = 'yaml-language-server',
            }
          }
        }
      })
      vim.lsp.enable('helm_ls')

      -- Format Terraform files on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.tf", "*.tfvars" },
        callback = function()
          vim.lsp.buf.format()
        end,
      })

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
