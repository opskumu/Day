" Vundle 管理配置
set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#rc()

" let Vundle manage Vundle
" required!
Plugin 'gmarik/vundle'
filetype plugin indent on
syntax on

" 安装插件
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'Valloric/YouCompleteMe'
" 退出 insert 模式自动关闭预览
" let g:ycm_autoclose_preview_window_after_insertion=1
let g:ycm_autoclose_preview_window_after_completion=1
Plugin 'altercation/vim-colors-solarized'

" 主题配置
syntax enable
set background=dark
colorscheme solarized
let g:solarized_termcolors=256

" syntax enable
" set background=light
" colorscheme solarized

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 基本配置
" 显示行号
set rnu
" set number
" set nonumber


" 在窗口的右下角显示当前光标的位置
set ruler
" set noruler

" 查找区分大小写
set ignorecase
" set noignorecase

" 在输入部分查找模式时显示相应的匹配点。
set incsearch
" set noincsearch

" 在窗口右下角，标尺的右边显示未完成的命令
set showcmd
" set noshowcmd

" 设定显示消息所用的行数
" set cmdheight 2

" 自动保存
set autowrite
" set noautowrite

" set modelines=10

set viminfo=""

set list
" 显示TAB成 ">---" 行尾多余的空白成 "-"
set listchars=tab:>-,trail:-

" 高亮显示所有匹配的地方
set hlsearch
" set nohlsearch

" 设置对齐线和相应颜色
set colorcolumn=81
highlight colorcolumn ctermbg=2

set ts=4
set autoindent shiftwidth=4
set expandtab
set smarttab
set encoding=utf8
set fileencodings=utf8

" 修复 BackSpace 键问题
set backspace=indent,eol,start

" 新建 py 自动添加标头
function HeaderPython()
    call setline(1, "#!/usr/bin/env python")
    call append(1, "# -*- coding: utf-8 -*-")
    normal G
    normal o
    normal o
    endf
    autocmd bufnewfile *.py call HeaderPython()
