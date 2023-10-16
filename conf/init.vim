set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

" trouble plug
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

if &wildoptions =~ "pum"
    cnoremap <expr> <up> pumvisible() ? "<C-p>" : "<up>"
    cnoremap <expr> <down> pumvisible() ? "<C-n>" : "<down>"
endif
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
