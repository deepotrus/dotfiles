inoremap jk <Esc>
inoremap kj <Esc>
set number

call plug#begin()
Plug 'dylanaraps/wal.vim'
call plug#end()

colorscheme wal

call plug#begin()
Plug 'preservim/nerdtree'
call plug#end()

nnoremap <F3> :NERDTreeToggle<CR>

" Notes
" after adding a plugin, open vim and :PlugInstall
