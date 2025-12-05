" Install vim plugin manager
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Then open vim and :PlugInstall

inoremap jk <Esc>
inoremap kj <Esc>
set number

" OSC 52 clipboard for SSH
function! OscYank(text) abort
  let encoded = substitute(system('base64', a:text), '\n', '', 'g')
  let seq = printf("\033]52;c;%s\007", encoded)
  call system('printf "' . seq . '" > /dev/tty')
endfunction

autocmd TextYankPost * if v:event.operator is 'y' | call OscYank(@") | endif

" Plugins if vim-plug available
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin()
  Plug 'dylanaraps/wal.vim'
  Plug 'preservim/nerdtree'
  call plug#end()
  nnoremap <F3> :NERDTreeToggle<CR>
endif
