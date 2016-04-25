"""""""""""""""""""""""""""""""Vundle 插件管理""""""""""""""""""""""""""""""""""
set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()
" let Vundle manage Vundle
" required!
Plugin 'gmarik/vundle'

" 安装插件
Plugin 'hynek/vim-python-pep8-indent'                   " Python 插件
Plugin 'Valloric/YouCompleteMe'                         " 代码自动补全功能
let g:ycm_autoclose_preview_window_after_completion=1   " 完成之后自动关闭预览
Plugin 'altercation/vim-colors-solarized'               " solarized 主题
Plugin 'fatih/vim-go'                                   " vim go 插件
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

Plugin 'scrooloose/nerdtree'                             " vim 目录插件
map <C-n> :NERDTreeToggle<CR>                            " 设置目录索引快捷键

call vundle#end()
filetype plugin indent on
"""""""""""""""""""""""""""""""Vundle 插件管理""""""""""""""""""""""""""""""""""


" 主题配置
"
syntax enable
set background=dark
colorscheme solarized
" set background=light
" colorscheme solarized
call togglebg#map("<F5>")


" 基本配置
"
" 显示行号
set relativenumber
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

set viminfo=""

set list
" 显示TAB成 ">---" 行尾多余的空白成 "-"
set listchars=tab:>-,trail:-

" 高亮显示所有匹配的地方
set hlsearch
" set nohlsearch

" 设置对齐线和相应颜色
set colorcolumn=81
highlight colorcolumn ctermbg=1

" 设置 tabspace
set ts=4
set autoindent shiftwidth=4
set expandtab
set smarttab

" 设置 utf8 编码
set encoding=utf8
set fileencodings=utf8

" 修复 MAC 下 BackSpace 键问题
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
