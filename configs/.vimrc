" Check for Plug, install if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
"  You will load your plugin here
"  Make sure you use single quotes
" Initialize plugin system
Plug 'tomtom/tcomment_vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'
Plug 'sheerun/vim-polyglot'
Plug 'vim-syntastic/syntastic'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-vinegar'
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ','

" Turn of arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Turn of arrow keys insert mode
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Leader C for code related mapping, Leader F for file related, Leader B for
" buffer related mappings 

" Comment
noremap <silent> <Leader>cc :TComment<CR> 

" CtrlP fuzzy search
nnoremap <silent> <Leader>f :CtrlP<CR>
nnoremap <silent> <Leader>fm :CtrlPMRU<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctrl B for buffer related mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <Leader>b :CtrlPBuffer<CR> " cycle between buffer
nnoremap <silent> <Leader>bb :bn<CR> "create (N)ew buffer
nnoremap <silent> <Leader>bd :bdelete<CR> "(D)elete the current buffer
nnoremap <silent> <Leader>bu :bunload<CR> "(U)nload the current buffer
nnoremap <silent> <Leader>bl :setnomodifiable<CR> " (L)ock the current buffer"

" Tabular
vnoremap <silent> <Leader>cee    :Tabularize /=<CR>
vnoremap <silent> <Leader>cet    :Tabularize /#<CR>
vnoremap <silent> <Leader>ce     :Tabularize /

" Vinegar close netrw buffer
autocmd FileType netrw setl bufhidden=wipe
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visuals
""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Mark column 81, to promote 80 column lines
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn','\%81v', 100)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#                                   "syntastic
set statusline+=%{SyntasticStatuslineFlag()}                    "syntastic
set statusline+=%*                                              "syntastic

let g:syntastic_always_populate_loc_list = 1                    "syntastic
let g:syntastic_auto_loc_list = 1                               "syntastic
let g:syntastic_check_on_open = 1                               "syntastic
let g:syntastic_check_on_wq = 0                                 "syntastic

set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

let g:solarized_contrast="high"                                 
"vim-colors-solarized
set background=dark
colorscheme solarized                                           
"vim-colors-solorized

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline

let g:lightline = { 'colorscheme': 'solarized', }               
"vim-lightline
set laststatus=2                                                
"vim-lightline
set noshowmode                                                  
"vim-lightline
