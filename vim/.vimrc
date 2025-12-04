inoremap jk <Esc>
inoremap kj <Esc>
set number

" systemwide copy paste from vim, requirements: sudo apt install vim-gtk3
" with this you can yank from vim and past anywhere
set clipboard=unnamedplus

call plug#begin()
Plug 'dylanaraps/wal.vim'
Plug 'preservim/nerdtree'
call plug#end()

colorscheme wal

nnoremap <F3> :NERDTreeToggle<CR>

" Notes
" after adding a plugin, open vim and :PlugInstall
