" Check for Plug, install if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'bfrg/vim-jq'
Plug 'arcticicestudio/nord-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'bfrg/vim-jq'
call plug#end()

nnoremap <SPACE> <Nop>
let mapleader = " "

set nocompatible
syntax on
filetype plugin indent on

" Nord theme config
colorscheme nord
let g:nord_cursor_line_number_background = 1
let g:nord_italic_comments = 1

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
set ts=2
set expandtab
set shiftwidth=2
set number relativenumber
set splitbelow splitright
set linebreak
set noshowmode

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
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>g  :G<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gd :Gvdiffsplit<cr>

" Bind Ctrl-P to use fzf 'Files' command now
nnoremap <c-p> :Files<cr>

" Improve search UI
set hlsearch incsearch
nnoremap <leader>h :set hls!<cr>

" Integrate Limelight with Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Coc config
let g:coc_node_path = $NODE_PATH

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Use lightline with gitbranch
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
