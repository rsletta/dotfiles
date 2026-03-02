-- Oh My Eyes! colorscheme for Neovim
-- High contrast theme with vibrant colors on pure black
-- Warning: May cause extreme visibility

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'oh-my-eyes'

-- Color palette (boosted saturation for better contrast)
local colors = {
  black = '#000000',
  red = '#ff0000',
  green = '#00ff00',
  yellow = '#ffff00',
  blue = '#0055ff',
  magenta = '#ff00ff',
  cyan = '#00ffff',
  white = '#c7c7c7',
  bright_black = '#686868',
  bright_red = '#ff4444',
  bright_green = '#44ff44',
  bright_yellow = '#ffff44',
  bright_blue = '#4444ff',
  bright_magenta = '#ff44ff',
  bright_cyan = '#44ffff',
  bright_white = '#ffffff',
}

local function hi(group, opts)
  local cmd = 'highlight ' .. group
  if opts.fg then cmd = cmd .. ' guifg=' .. opts.fg end
  if opts.bg then cmd = cmd .. ' guibg=' .. opts.bg end
  if opts.bold then cmd = cmd .. ' gui=bold' end
  if opts.italic then cmd = cmd .. ' gui=italic' end
  vim.cmd(cmd)
end

-- Editor
hi('Normal', { fg = colors.white, bg = colors.black })
hi('NormalNC', { fg = colors.white, bg = colors.black })
hi('LineNr', { fg = colors.bright_black })
hi('CursorLineNr', { fg = colors.bright_white, bold = true })
hi('Visual', { bg = '#1a1a1a' })
hi('SignColumn', { bg = colors.black })
hi('StatusLine', { fg = colors.white, bg = '#1a1a1a' })

-- Syntax (generic)
hi('Comment', { fg = colors.bright_black, italic = true })
hi('String', { fg = colors.bright_magenta })
hi('Number', { fg = colors.bright_yellow })
hi('Boolean', { fg = colors.bright_yellow })
hi('Keyword', { fg = colors.blue })
hi('Function', { fg = colors.bright_green })
hi('Type', { fg = colors.bright_cyan })
hi('Identifier', { fg = colors.white })
hi('Constant', { fg = colors.bright_yellow })
hi('Statement', { fg = colors.blue })
hi('Operator', { fg = colors.bright_yellow })
hi('PreProc', { fg = colors.blue })
hi('Error', { fg = colors.bright_red })

-- Treesitter
hi('@keyword', { fg = colors.blue })
hi('@keyword.function', { fg = colors.blue })
hi('@keyword.return', { fg = colors.blue })
hi('@variable', { fg = colors.white })
hi('@variable.builtin', { fg = colors.bright_cyan })
hi('@function', { fg = colors.bright_green })
hi('@function.call', { fg = colors.bright_green })
hi('@method', { fg = colors.bright_green })
hi('@method.call', { fg = colors.bright_green })
hi('@type', { fg = colors.bright_cyan })
hi('@type.builtin', { fg = colors.bright_cyan })
hi('@string', { fg = colors.bright_magenta })
hi('@number', { fg = colors.bright_yellow })
hi('@boolean', { fg = colors.bright_yellow })
hi('@constant', { fg = colors.bright_yellow })
hi('@operator', { fg = colors.bright_yellow })
hi('@punctuation.bracket', { fg = colors.white })
hi('@punctuation.delimiter', { fg = colors.white })
