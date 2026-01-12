-- ERF edit - make nvim aware of openAI key
local env = vim.fn.expand("~/.config/openai/.env")
if vim.fn.filereadable(env) == 1 then
  for _, line in ipairs(vim.fn.readfile(env)) do
    local key, value = line:match("^([^=]+)=(.+)$")
    if key and value then
      vim.fn.setenv(key, value)
    end
  end
end

-- Package manager setup using plug.vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.local/share/nvim/plugged')

-- Plugins
Plug('scrooloose/nerdtree', { on = 'NERDTreeToggle' })
Plug('jalvesaq/Nvim-R')
Plug('tpope/vim-surround')
Plug('junegunn/fzf', { dir = '~/.fzf', ['do'] = './install --all' })
Plug('easymotion/vim-easymotion')
Plug('jpalardy/vim-slime')
Plug('hanschen/vim-ipython-cell', { ['for'] = 'python' })
Plug('Shougo/deoplete.nvim', { ['do'] = ':UpdateRemotePlugins' })
Plug('zchee/deoplete-jedi')
Plug('tmhedberg/SimpylFold')
Plug('Konfekt/FastFold')
Plug('vim-airline/vim-airline')
Plug('machakann/vim-highlightedyank')
Plug('terryma/vim-multiple-cursors')
Plug('dense-analysis/ale')
Plug('nvie/vim-flake8')
Plug('puremourning/vimspector')
Plug("jackMort/ChatGPT.nvim")
Plug("MunifTanjim/nui.nvim")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")


vim.call('plug#end')

-- General settings
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.shiftwidth = 4
vim.opt.clipboard:append('unnamedplus')
vim.opt.colorcolumn = "79"
vim.cmd([[colorscheme blue]])

-- Nvim-R settings
vim.g.R_rconsole_width = 0
vim.g.R_rconsole_height = 15
-- vim.g.loaded_nvimrplugin = 1 -- Disable debugging support

-- Keyboard shortcuts
vim.api.nvim_set_keymap('n', '<F2>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- python compiler
vim.g.python3_host_prog = '/home/blueaz/Python/.venv/bin/python'

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

-- Vimspector bindings
local vimspector_mappings = {
  ['<Leader>dd'] = ':call vimspector#Launch()<CR>',
  ['<Leader>dr'] = ':call vimspector#Reset()<CR>',
  ['<Leader>dc'] = ':call vimspector#Continue()<CR>',
  ['<Leader>dt'] = ':call vimspector#ToggleBreakpoint()<CR>',
  ['<Leader>dT'] = ':call vimspector#ClearBreakpoints()<CR>',
  ['<Leader>dk'] = '<Plug>VimspectorRestart',
  ['<Leader>dh'] = '<Plug>VimspectorStepOut',
  ['<Leader>dl'] = '<Plug>VimspectorStepInto',
  ['<Leader>dj'] = '<Plug>VimspectorStepOver',
  ['<Leader>de'] = 'VimspectorEval',
  ['<Leader>dw'] = 'VimspectorWatch',
  ['<Leader>do'] = 'VimspectorShowOutput',
}

for key, cmd in pairs(vimspector_mappings) do
  vim.api.nvim_set_keymap('n', key, cmd, { noremap = true, silent = true })
end

vim.g.vimspector_enable_mappings = 'HUMAN'

-- Clipboard shortcut
vim.api.nvim_set_keymap('n', '<leader>y', ':let @" = system("wl-copy", join(getreg(\'"\', 1, 1), "\\n"), {"options": "-t text/plain"})<CR>', { noremap = true, silent = true })

-- ALE settings
vim.g.ale_linters = { python = { 'flake8' } }

-- Deoplete settings
vim.g['deoplete#enable_at_startup'] = 1

-- Slime configuration
vim.g.slime_target = 'tmux'
vim.g.slime_default_config = { socket_name = vim.fn.split(vim.env.TMUX, ',')[1], target_pane = ':1.1' }
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
vim.g.rst_fold_enabled = 1
vim.g.tex_fold_enabled = 1
vim.g.vimsyn_folding = 'af'
vim.g.xml_syntax_folding = 1
vim.g.javaScript_fold = 1
vim.g.sh_fold_enabled = 7
vim.g.zsh_fold_enable = 1
vim.g.ruby_fold = 1
vim.g.perl_fold = 1
vim.g.perl_fold_blocks = 1
vim.g.r_syntax_folding = 1
vim.g.rust_fold = 1
vim.g.php_folding = 1
vim.g.fortran_fold = 1
vim.g.clojure_fold = 1
vim.g.baan_fold = 1

-- ERF addition
pcall(function()
  require("chatgpt").setup({
    -- By default it uses OPENAI_API_KEY from env, so no key pasted here.
    -- Optional: customize UI/behavior later.
  })
end)

