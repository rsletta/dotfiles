-- Telescope setup
local action_set = require('telescope.actions.set')
require('telescope').setup{
  defaults = {
      prompt_prefix = "$ ",
      pickers = {
        find_files = {
          hidden = true
        }
      },
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
