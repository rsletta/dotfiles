return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      }
    },
    config = function()
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
      require("lspconfig").lua_ls.setup {}
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#yamlls
      require("lspconfig").yamlls.setup {}
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#helm_ls
      require'lspconfig'.helm_ls.setup{
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = 'yaml-language-server',
            }
          }
        }
      }
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#dockerls
      require("lspconfig").dockerls.setup {}
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#docker_compose_language_service
      require'lspconfig'.docker_compose_language_service.setup{}
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#marksman
      require'lspconfig'.marksman.setup{}
    end,
  }
}
