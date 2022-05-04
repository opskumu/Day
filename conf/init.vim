set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
if &wildoptions =~ "pum"
    cnoremap <expr> <up> pumvisible() ? "<C-p>" : "<up>"
    cnoremap <expr> <down> pumvisible() ? "<C-n>" : "<down>"
endif