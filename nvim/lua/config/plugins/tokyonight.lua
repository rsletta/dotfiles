return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "night", -- highest-contrast variant: near-black background
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = false },
    },
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.opt.background = "dark"
    vim.cmd("colorscheme tokyonight-night")
  end,
}
