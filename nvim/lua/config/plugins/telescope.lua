return {
  {
  "nvim-telescope/telescope.nvim", tag="0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules",
            ".ruff_cache",
            ".git/",
            ".mypy_cache",
          },
        },
        pickers = {
          find_files = {
            no_ignore = true,
          },
        },
        extensions = {
          file_browser = {
            hidden = { file_browser = true, folder_browser = true },
            respect_gitignore = false,
          },
        },
      })
      require("telescope").load_extension("file_browser")
      -- Telescope key mappings
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>fx", ":Telescope file_browser<CR>")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Search buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "search help" })
      vim.keymap.set("n", "<leader>fw", function() builtin.find_files({ cwd = "~/vault" }) end)
       vim.keymap.set("n", "<leader>fzb",
       function() builtin.current_buffer_fuzzy_find({ sorting_strategy = "ascending", prompt_position = "top" }) end)
       vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Find references" })
   end
  }
}
