" Check for Plug, install if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Visuals
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'morhetz/gruvbox'

" Telescope stuff
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Writing & Markdown
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'preservim/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Tools
Plug 'tpope/vim-surround'
Plug 'bfrg/vim-jq'

" Git
Plug 'tpope/vim-fugitive'
call plug#end()

nnoremap <SPACE> <Nop>
let mapleader = " "

set nocompatible
syntax on
filetype plugin indent on

" Set color scheme
colorscheme gruvbox

" Load personal lua config
lua require('rsletta')

" Ignore files in search
set wildignore+=**/node_modules/*
set wildignore+=**/.git/*
" Treesitter
lua require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}

" Telescope config
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fw <cmd>Telescope find_files cwd=~/vault<cr>


" Disables automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Remove all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Get correct comment highlighting in json
autocmd FileType json syntax match Comment +\/\/.\+$+

" Check leading whitespace
set listchars=tab:▸·,eol:¬
nnoremap <silent> <leader>l :set list!<cr>

set background=dark
set encoding=utf-8
set colorcolumn=80
set ts=4
set sts=4
set expandtab
set shiftwidth=2
set number relativenumber
set splitbelow splitright
set linebreak
set noshowmode
set scrolloff=10
set noswapfile

" Unified clipboard WSL2
set clipboard+=unnamedplus
let g:clipboard = {
           \   'name': 'win32yank-wsl',
           \   'copy': {
           \      '+': 'win32yank.exe -i --crlf',
           \      '*': 'win32yank.exe -i --crlf',
           \    },
           \   'paste': {
           \      '+': 'win32yank.exe -o --lf',
           \      '*': 'win32yank.exe -o --lf',
           \   },
           \   'cache_enabled': 0,
           \ }

" See https://github.com/neovim/neovim/issues/5559#issuecomment-258143499
let g:is_bash = 1

noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Remap save and quit
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>r :so $MYVIMRC<cr>

" Git stuff
nnoremap <leader>gs :G<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gd :Gvdiffsplit<cr>
nnoremap <leader>gj :diffget //3<CR>
nnoremap <leader>gf :diffget //2<CR>

" Improve search UI
set hlsearch incsearch
nnoremap <leader>h :set hls!<cr>

" Automatically turn on auto-save for markdown files
autocmd FileType markdown let g:auto_save = 0

" Integrate Limelight with Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_follow_anchor = 0
let g:vim_markdown_new_list_item_indent = 0

" vim-markdown-preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }
let g:mkdp_page_title = '「${name}」'
let g:mkdp_filetypes = ['markdown']
