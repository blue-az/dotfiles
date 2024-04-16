"General parameters  
color blue
set termguicolors
set number
set mouse=a
set sw=4
set clipboard+=unnamedplus


"Nvim-R parameters
let R_rconsole_width = 0
let R_rconsole_height = 15
"let g:loaded_nvimrplugin = 1 "disable debugging support

"Keyboard shortcuts
map <F2> :NERDTreeToggle<CR>
:imap jk <Esc>

"Python file defaults
au BufNewFile, BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=4
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix

" vimspector bindings
nnoremap <Leader>dd :call vimspector#Launch()<CR>
nnoremap <Leader>dr :call vimspector#Reset()<CR>
nnoremap <Leader>dc :call vimspector#Continue()<CR>

nnoremap <Leader>dt :call vimspector#ToggleBreakpoint()<CR>
nnoremap <Leader>dT :call vimspector#ClearBreakpoints()<CR>

nmap <Leader>dk <Plug>VimspectorRestart
nmap <Leader>dh <Plug>VimspectorStepOut
nmap <Leader>dl <Plug>VimspectorStepInto
nmap <Leader>dj <Plug>VimspectorStepOver
nmap <Leader>de VimspectorEval
nmap <Leader>dw VimspectorWatch
nmap <Leader>do VimspectorShowOutput
let g:vimspector_enable_mappings = 'HUMAN'

nnoremap <leader>y :let @" = system('wl-copy', join(getreg('"', 1, 1), "\n"), {'options': '-t text/plain'})<CR>

"Ale
let g:ale_linters = {'python': ['flake8']}
let b:ale_fixers = ['eslint']
let g:ale_fix_on_save = 1
"Lint style
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

"Deoplete
let g:deoplete#enable_at_startup = 1

"Slime configuration
" always use tmux
let g:slime_target = 'tmux'
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.1"}
let g:slime_paste_file = "$HOME/.slime_paste"

"------------------------------------------------------------------------------
" ipython-cell configuration
"------------------------------------------------------------------------------
" Keyboard mappings. <Leader> is \ (backslash) by default

" map <Leader>s to start IPython
nnoremap <Leader>s :SlimeSend1 ipython --matplotlib<CR>

" map <Leader>r to run script
nnoremap <Leader>r :IPythonCellRun<CR>

" map <Leader>R to run script and time the execution
nnoremap <Leader>R :IPythonCellRunTime<CR>

" map <Leader>c to execute the current cell
nnoremap <Leader>c :IPythonCellExecuteCell<CR>

" map <Leader>C to execute the current cell and jump to the next cell
nnoremap <Leader>pa :IPythonCellExecuteCellJump<CR>

" map <Leader>l to clear IPython screen
nnoremap <Leader>l :IPythonCellClear<CR>

" map <Leader>x to close all Matplotlib figure windows
nnoremap <Leader>x :IPythonCellClose<CR>

" map [c and ]c to jump to the previous and next cell header
nnoremap [p :IPythonCellPrevCell<CR>
nnoremap ]p :IPythonCellNextCell<CR>

" map <Leader>h to send the current line or current selection to IPython
nmap <Leader>d <Plug>SlimeLineSend
xmap <Leader>d <Plug>SlimeRegionSend

" map <Leader>p to run the previous command
nnoremap <Leader>P :IPythonCellPrevCommand<CR>

" map <Leader>Q to restart ipython
nnoremap <Leader>Q :IPythonCellRestart<CR>

" map <Leader>d to start debug mode
nnoremap <Leader>h :SlimeSend1 %debug<CR>

" map <Leader>q to exit debug mode or IPython
nnoremap <Leader>q :SlimeSend1 exit<CR>

" map <F9> and <F10> to insert a cell header tag above/below and enter insert mode
nmap <F9> :IPythonCellInsertAbove<CR>a
nmap <F10> :IPythonCellInsertBelow<CR>a

" also make <F9> and <F10> work in insert mode
imap <F9> <C-o>:IPythonCellInsertAbove<CR>
imap <F10> <C-o>:IPythonCellInsertBelow<CR>

"------------------------------------------------------------------------------
"FastFold setup
nmap zuz <Plug>(FastFoldUpdate)
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']

let g:markdown_folding = 1
let g:rst_fold_enabled = 1
let g:tex_fold_enabled = 1
let g:vimsyn_folding = 'af'
let g:xml_syntax_folding = 1
let g:javaScript_fold = 1
let g:sh_fold_enabled= 7
let g:zsh_fold_enable = 1
let g:ruby_fold = 1
let g:perl_fold = 1
let g:perl_fold_blocks = 1
let g:r_syntax_folding = 1
let g:rust_fold = 1
let g:php_folding = 1
let g:fortran_fold=1
let g:clojure_fold = 1
let g:baan_fold=1

"Snippet remap
imap <C-J> <esc>a<Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

"------------------------------------------------------------------------------
"Plugin Section
"------------------------------------------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')
"NerdTree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Nvim-R
Plug 'jalvesaq/Nvim-R'
"Plug 'jalvesaq/vim-r-plugin'
"vim surround
Plug 'tpope/vim-surround'
"Unite
"Plug 'Shougo/unite.vim'
"fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Easy Motion
Plug 'easymotion/vim-easymotion'
"Vim-slime and ipython cell
Plug 'jpalardy/vim-slime'
Plug 'hanschen/vim-ipython-cell', { 'for': 'python' }
" deoplete jedi
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
" Code folding - simply and fast
Plug 'tmhedberg/SimpylFold'
Plug 'Konfekt/FastFold'
" Airline
Plug 'vim-airline/vim-airline'
" Highlight Yank
Plug 'machakann/vim-highlightedyank'
" Multiple cursors
Plug 'terryma/vim-multiple-cursors'
"Linting and syntax checking
Plug 'dense-analysis/ale'
Plug 'nvie/vim-flake8'
" Breakpoints
Plug 'puremourning/vimspector'
" System copy
Plug 'christoomey/vim-system-copy'
" Autocomplete
Plug 'Valloric/YouCompleteMe'
call plug#end()
" Syntax highlighting
Plug 'pangloss/vim-javascript'
" Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'grvcoelho/vim-javascript-snippets'
