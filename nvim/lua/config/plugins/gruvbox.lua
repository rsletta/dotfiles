return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      terminal_colors = true,
      contrast = "hard",
      transparent_mode = false,
      bold = true,
      italic = {
        strings = false,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      overrides = {
        -- Keywords (import, from, const, let, return, new, interface, type, if, etc.) - RED
        ["@keyword"] = { fg = "#fb4934", bold = true },
        ["@keyword.import"] = { fg = "#fb4934", bold = true },
        ["@keyword.repeat"] = { fg = "#fb4934", bold = true },
        ["@keyword.return"] = { fg = "#fb4934", bold = true },
        ["@keyword.conditional"] = { fg = "#fb4934", bold = true },
        ["@keyword.type"] = { fg = "#fb4934", bold = true },
        ["@keyword.function"] = { fg = "#fb4934", bold = true },
        
        -- Types (string, boolean, etc.) - YELLOW
        ["@type"] = { fg = "#fabd2f" },
        ["@type.builtin"] = { fg = "#fabd2f" },
        ["@type.definition"] = { fg = "#fabd2f" },
        
        -- Function and method calls - YELLOW
        ["@function.call"] = { fg = "#fabd2f" },
        ["@function.method.call"] = { fg = "#fabd2f" },
        ["@lsp.type.method"] = { fg = "#fabd2f" },
        
        -- Svelte runes ($state, $derived) - YELLOW BOLD
        ["@variable.builtin"] = { fg = "#fabd2f", bold = true },
        
        -- Property access - YELLOW
        ["@property"] = { fg = "#fabd2f" },
        ["@lsp.type.property"] = { fg = "#fabd2f" },
        
        -- Operators - ORANGE
        ["@operator"] = { fg = "#fe8019" },
        
        -- Strings - GREEN (default gruvbox green)
        ["@string"] = { fg = "#b8bb26" },
      }
    })
    
    vim.opt.background = "dark"
    vim.cmd("colorscheme gruvbox")
  end,
}
