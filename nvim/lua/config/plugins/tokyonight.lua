return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    style = "storm",
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = false },
      keywords = { italic = false },
      functions = { bold = true },
    },
  },
}
