-- Bootstrap nvim config
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Get other global keymaps
require("config.keymaps")

-- Bootstrap lazy plugin manager
require("config.lazy")

-- Neovim options
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.encoding = "utf-8"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "120"
vim.opt.signcolumn = "yes"
vim.opt.ts = 4
vim.opt.sts = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.showmode = true
vim.opt.scrolloff = 10
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.wildignore:append { "**/node_modules/*", "**/.git/*" }

-- Auto commands
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
        clear = true
    }),
    callback = function()
        vim.highlight.on_yank()
    end
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Disable automatic comment continuation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- Highlight comments in JSON files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    command = "syntax match Comment +\\/\\/.*$+",
})
