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
Plug 'kyazdani42/nvim-web-devicons'

" Telescope stuff
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Writing & Markdown
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'preservim/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'godlygeek/tabular'

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

" Color scheme config
colorscheme gruvbox

" Load personal lua config
lua require('rsletta')

" Ignore files in search
set wildignore+=**/node_modules/*
set wildignore+=**/.git/*

" Telescope config
" Find files using Telescope command-line sugar.
nnoremap <leader>fx <cmd>Telescope file_browser<cr>
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fw <cmd>Telescope find_files cwd=~/vault<cr>
nnoremap <leader>fzb <cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top <cr>

" Quick buffer navigation
nnoremap <leader>bn :bnext<cr>
nnoremap <leader>bp :bprevious<cr>
nnoremap <leader>bs :buffers<cr>:buffer<space>

" Disables automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Remove all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Get correct comment highlighting in json
autocmd FileType json syntax match Comment +\/\/.\+$+

" Check leading whitespace
let g:gruvbox_baby_telescope_theme = 1
set listchars=tab:▸·,eol:¬
nnoremap <silent> <leader>l :set list!<cr>

set background=dark
set encoding=utf-8
set colorcolumn=120
set ts=4
set sts=4
set expandtab
set shiftwidth=2
set number relativenumber
set splitbelow splitright
set noshowmode
set scrolloff=10
set noswapfile
set signcolumn=yes
" Soft wrap lines. Keeps indentation of parent. Does not split words.
set wrap linebreak nolist breakindent formatoptions=1 lbr

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
nnoremap <leader>gis :G<cr>
nnoremap <leader>gib :Gblame<cr>
nnoremap <leader>gid :Gvdiffsplit<cr>
nnoremap <leader>gij :diffget //3<CR>
nnoremap <leader>gif :diffget //2<CR>

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
