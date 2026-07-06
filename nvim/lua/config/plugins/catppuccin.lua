return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
    })

    vim.opt.background = "dark"
    vim.cmd("colorscheme catppuccin")
  end,
}
