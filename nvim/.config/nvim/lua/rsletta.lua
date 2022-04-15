-- Personal Neovim config

-- Telescope setup
local action_set = require('telescope.actions.set')
require('telescope').setup{
  defaults = {
      prompt_prefix = "$ ",
      mappings = {
        i = {
          -- INSERT MODE mappings
          -- ["<c-a>"] = function() something end
        }
      }
    }
}
require('telescope').load_extension('fzf')
require("telescope").load_extension "file_browser"

-- Built-in LSP setup
require'lspconfig'.tsserver.setup{
  on_attach = function()
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer=0})
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer=0})
  end,
}
