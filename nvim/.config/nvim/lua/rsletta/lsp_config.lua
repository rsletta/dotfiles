-- Built-in LSP setup

-- TypeScript / JavaScript
require'lspconfig'.tsserver.setup{
  on_attach = function()
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer=0})
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer=0})
  end,
}

-- JSON
require'lspconfig'.jsonls.setup{
  on_attach = function()
    print('JSON ls attached')
  end,
}

-- HTML
require'lspconfig'.html.setup{
  on_attach = function()
    print('html ls attached')
  end,
}

-- CSS
require'lspconfig'.cssls.setup{
  on_attach = function()
    print('cssls attached')
  end,
}

-- Vue.js
require'lspconfig'.vuels.setup{
  on_attach = function()
    print('Vuels attached')
  end,
}

-- bash
require'lspconfig'.bashls.setup{
  on_attach = function()
    print('bashls attached')
  end,
}


