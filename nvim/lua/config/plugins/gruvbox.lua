return {
  -- https://github.com/ellisonleao/gruvbox.nvim
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup {
        style = "dark",
        terminal_colors = true,
        transparent_mode = false,
        dim_inactive = false
      }
      vim.cmd.colorscheme "gruvbox"
    end
  }
}
