inoremap jk <Esc>
inoremap kj <Esc>
set number

call plug#begin()
Plug 'dylanaraps/wal.vim'
Plug 'preservim/nerdtree'
call plug#end()

colorscheme wal

nnoremap <F3> :NERDTreeToggle<CR>

" Notes
" after adding a plugin, open vim and :PlugInstall
