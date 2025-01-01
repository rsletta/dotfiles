local treesitter = require('nvim-treesitter.configs')

treesitter.setup {
  highlight = {
    enable = true
  },
  incremental_selection = {
    enable = true
  },
  textobjects = {
    enable = true
  }
}

