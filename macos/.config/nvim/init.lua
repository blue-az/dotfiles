-- Package manager setup using plug.vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.local/share/nvim/plugged')

-- Plugins
Plug('scrooloose/nerdtree', { on = 'NERDTreeToggle' })
Plug('tpope/vim-surround')
Plug('junegunn/fzf', { dir = '~/.fzf', ['do'] = './install --all' })
Plug('junegunn/fzf.vim')
Plug('easymotion/vim-easymotion')
Plug('jpalardy/vim-slime')
Plug('hanschen/vim-ipython-cell', { ['for'] = 'python' })
Plug('tmhedberg/SimpylFold')
Plug('Konfekt/FastFold')
Plug('vim-airline/vim-airline')
Plug('machakann/vim-highlightedyank')
Plug('dense-analysis/ale')
Plug('nvie/vim-flake8')

vim.call('plug#end')

-- General settings
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.shiftwidth = 4
vim.opt.clipboard:append('unnamedplus')
vim.opt.colorcolumn = "79"
vim.cmd([[colorscheme blue]])

-- Keyboard shortcuts
vim.api.nvim_set_keymap('n', '<F2>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Python file defaults
vim.cmd([[
  augroup python_setup
    autocmd!
    autocmd BufNewFile,BufRead *.py
        \ set tabstop=4 |
        \ set softtabstop=4 |
        \ set shiftwidth=4 |
        \ set expandtab |
        \ set autoindent |
        \ set fileformat=unix
  augroup END
]])

-- ALE settings
vim.g.ale_linters = { python = { 'flake8' } }

-- Slime configuration (for tmux)
vim.g.slime_target = 'tmux'
vim.g.slime_paste_file = vim.env.HOME .. '/.slime_paste'

-- IPython cell configuration
local ipython_mappings = {
  ['<Leader>s'] = ':SlimeSend1 ipython --matplotlib<CR>',
  ['<Leader>r'] = ':IPythonCellRun<CR>',
  ['<Leader>R'] = ':IPythonCellRunTime<CR>',
  ['<Leader>c'] = ':IPythonCellExecuteCell<CR>',
  ['<Leader>pa'] = ':IPythonCellExecuteCellJump<CR>',
  ['<Leader>l'] = ':IPythonCellClear<CR>',
  ['<Leader>x'] = ':IPythonCellClose<CR>',
  ['[p'] = ':IPythonCellPrevCell<CR>',
  [']p'] = ':IPythonCellNextCell<CR>',
  ['<Leader>d'] = '<Plug>SlimeLineSend',
  ['<Leader>P'] = ':IPythonCellPrevCommand<CR>',
  ['<Leader>Q'] = ':IPythonCellRestart<CR>',
  ['<Leader>h'] = ':SlimeSend1 %debug<CR>',
  ['<Leader>q'] = ':SlimeSend1 exit<CR>',
}

for key, cmd in pairs(ipython_mappings) do
  vim.api.nvim_set_keymap('n', key, cmd, { noremap = true, silent = true })
end

vim.api.nvim_set_keymap('i', '<F9>', '<C-o>:IPythonCellInsertAbove<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<F10>', '<C-o>:IPythonCellInsertBelow<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F9>', ':IPythonCellInsertAbove<CR>a', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', ':IPythonCellInsertBelow<CR>a', { noremap = true, silent = true })

-- FastFold setup
vim.api.nvim_set_keymap('n', 'zuz', '<Plug>(FastFoldUpdate)', {})
vim.g.fastfold_savehook = 1
vim.g.fastfold_fold_command_suffixes = { 'x', 'X', 'a', 'A', 'o', 'O', 'c', 'C' }
vim.g.fastfold_fold_movement_commands = { ']z', '[z', 'zj', 'zk' }
vim.g.markdown_folding = 1
vim.g.tex_fold_enabled = 1
vim.g.sh_fold_enabled = 7
vim.g.zsh_fold_enable = 1
vim.g.python_fold = 1
