-- Writing & Markdown
{ "junegunn/goyo.vim" },
{ "junegunn/limelight.vim" },
{ "preservim/vim-markdown" },
{
"iamcco/markdown-preview.nvim",
build = "cd app && npm install",
ft = { "markdown" },
},
{ "godlygeek/tabular" },

-- Tools
{ "tpope/vim-surround" },
{ "bfrg/vim-jq" },

-- Git
{ "tpope/vim-fugitive" },

-- Markdown-preview
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_filetypes = { "markdown" }

-- Vim-markdown
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_follow_anchor = 0
vim.g.vim_markdown_new_list_item_indent = 0
