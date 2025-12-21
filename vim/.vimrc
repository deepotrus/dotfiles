inoremap jk <Esc>
inoremap kj <Esc>
set number
set relativenumber

" systemwide copy paste from vim, requirements: sudo apt install vim-gtk3
" with this you can yank from vim and past anywhere
set clipboard=unnamedplus

" Install vim plugin manager
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Then open vim and :PlugInstall
call plug#begin()
Plug 'dylanaraps/wal.vim'
Plug 'preservim/nerdtree'
call plug#end()

colorscheme wal
nnoremap <F3> :NERDTreeToggle<CR>
