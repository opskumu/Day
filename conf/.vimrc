""""""""""""""""""""""""""""""vim-plug 插件管理""""""""""""""""""""""""""""""""
set nocompatible
call plug#begin('~/.vim/plugged')

" 安装插件
"
" 状态栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='papercolor'
" let g:airline#extensions#tabline#enabled=1
" buffers switch 键映射
" nnoremap <Tab> :bnext<CR>
" nnoremap <S-Tab> :bprevious<CR>

" vim 主题
Plug 'altercation/vim-colors-solarized'
Plug 'NLKNguyen/papercolor-theme'
Plug 'cocopon/iceberg.vim'
Plug 'sainnhe/edge'

" 快速跳转
Plug 'easymotion/vim-easymotion'

" codeium
Plug 'Exafunction/codeium.vim'

" Git 插件
Plug 'tpope/vim-fugitive'

" vim 目录插件
Plug 'scrooloose/nerdtree'
" 设置目录索引快捷键
map <C-n> :NERDTreeToggle<CR>                           

" tagbar 依赖 `ctags`
Plug 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

" vim-go 插件
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" 自动获取依赖加入 import
let g:go_fmt_command="goimports"
let g:go_autodetect_gopath=1
let g:go_list_type="quickfix"
let g:go_highlight_types=1
let g:go_highlight_fields=1
let g:go_highlight_functions=1
let g:go_highlight_function_calls=1
let g:go_highlight_structs=1
let g:go_highlight_methods=1
let g:go_highlight_operators=1
let g:go_highlight_build_constraints=1
let g:go_highlight_extra_types=1
let g:go_highlight_generate_tags=1
let g:go_highlight_variable_declarations=1
let g:go_highlight_variable_assignments=1
let g:go_def_reuse_buffer=1
" let g:go_auto_sameids=1
" conflict with syntastic --> https://github.com/vim-syntastic/syntastic/blob/master/doc/syntastic.txt#L1150
" also ale --> https://github.com/w0rp/ale/issues/609
let g:go_fmt_fail_silently=1

" 补全插件
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" 语法检测
Plug 'dense-analysis/ale'
let g:ale_set_loclist=0
let g:ale_set_quickfix=1
let g:ale_fix_on_save=1
let g:ale_lint_on_enter=0
let g:ale_lint_on_insert_leave=0
let g:ale_lint_on_text_changed='never'
let g:ale_linters={'go': ['golangci-lint']}
let g:ale_go_golangci_lint_options='--fast'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" ansible syntax
Plug 'pearofducks/ansible-vim'

" json
Plug 'google/vim-jsonnet'

" 错误显示
Plug 'folke/trouble.nvim'

call plug#end()
""""""""""""""""""""""""""""""vim-Plug 插件管理""""""""""""""""""""""""""""""""

" 主题配置
"
syntax enable
" set background=dark
set background=light
set t_Co=256
" colorscheme solarized
" colorscheme papercolor
" colorscheme iceberg
colorscheme edge
call togglebg#map("<F5>")
if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

" 基本配置
"
" 显示行号
" set relativenumber
set number
" set nonumber

" 保留 undo
set hidden

" 在窗口的右下角显示当前光标的位置
set ruler
" set noruler

" 查找区分大小写
set ignorecase
" set noignorecase

" 在输入部分查找模式时显示相应的匹配点
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

" 高亮显示所有匹配的地方
set hlsearch
" set nohlsearch

" 高亮所在行
set cursorline
" set nocursorline 

" 设置对齐线和相应颜色
set colorcolumn=80
highlight OverLength ctermbg=red ctermfg=white guibg=#592929

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

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
if !has('nvim')
  set viminfo='10,\"100,:20,%,n~/.viminfo
endif

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" Maximum amount of memory (in Kbyte) to use for pattern matching
set maxmempattern=4000

" lua
lua <<EOF
  require"trouble".setup {
    mode = "quickfix",
    icons = false,
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
        -- icons / text used for a diagnostic
        error = "E",
        warning = "W",
        hint = "H",
        information = "I"
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
  }
EOF
