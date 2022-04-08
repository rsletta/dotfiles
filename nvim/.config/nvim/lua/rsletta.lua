-- Personal Neovim config

-- Telescope
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
require("telescope").load_extension "file_browser"
