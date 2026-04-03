-- bootstrap {{{

vim.loader.enable()

vim.env.PATH = vim.fn.expand('$HOME/.dotnet') .. ':' .. vim.env.PATH

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- }}}
-- {{{ colorscheme

vim.cmd([[colorscheme isekai]])

-- }}}
-- options {{{

local o = vim.opt
local g = vim.g

-- general
g.mapleader = ' '
o.undofile = true -- enable persistent undo
o.backup = false -- disable backup
o.confirm = true -- Confirm to save changes before exiting modified buffer
o.iskeyword = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part, default "@,48-57,_,192-255"
o.termguicolors = true

-- ui
o.winborder = 'rounded'
-- o.pumborder = 'rounded'
o.cursorline = true -- highlight the text line of the cursor
o.number = true -- show numberline
o.relativenumber = true -- show relative numberline
o.signcolumn = 'yes' -- always show the sign column

-- wrapping
o.wrap = true -- soft wrap lines
o.showbreak = '↪ '
o.breakindent = true -- make wrapped lines continue visually indented

-- special UI symbols
o.list = true -- show invisible characters.
o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> ,trail:·'
o.fillchars = 'eob: ,fold:┄,foldclose:,foldopen:'

-- statusline
o.laststatus = 0 -- never a statusline
o.ruler = false -- no position info at cmdline
o.showmode = false -- disable showing modes in command line since it's already in the status line

-- splitting
o.splitbelow = true -- splitting a new window below the current one
o.splitright = true -- splitting a new window at the right of the current one
o.splitkeep = 'screen'

-- scrolling
o.scrolloff = 15 -- minimum number of lines to keep above and below the cursor.

-- editing
o.updatetime = 200 -- length of time to wait before triggering the plugin
o.timeoutlen = 250 -- shorten key timeout length for which-key
o.inccommand = 'split' -- preview substitutions live

-- indenting
o.expandtab = true -- convert tabs to spaces
o.shiftwidth = 4 -- number of space inserted for indentation
o.softtabstop = 4 -- number of spaces that a <Tab> counts for.
o.tabstop = 4 -- number of space in a tab
o.smartindent = true -- do smart auto indenting.

-- searching
o.ignorecase = true -- ignore case during search
o.smartcase = true -- respect case if search pattern has upper case
o.hlsearch = true -- highlight search results as you type.

-- folding
o.foldmethod = 'marker'
o.foldmarker = '{{{,}}}' -- this is the default
o.foldlevel = 0 -- start with all folds closed
o.foldlevelstart = 0 -- open files with folds closed

-- clipboard
vim.schedule(function() -- to avoid increasing startup-time
    o.clipboard = 'unnamedplus' -- connection to the system clipboard
end)

-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- see full list:
-- https://github.com/neovim/neovim/tree/master/runtime/plugin
g.loaded_2html_plugin = 1
g.loaded_gzip = 1
g.loaded_man = 1
g.loaded_tarPlugin = 1
g.loaded_zipPlugin = 1
g.loaded_remote_plugins = 1

-- }}}
-- autocmd {{{

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
  group = highlight_group,
  pattern = '*',
})

-- }}}
-- mappings {{{

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<Esc>', function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = 'Close floats', silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('i', '<Up>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('i', '<Down>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('i', '<Left>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('i', '<Right>', '<Nop>', { noremap = true, silent = true })

vim.keymap.set('n', '<Up>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Down>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Left>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set('n', '<Right>', '<Nop>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzv', { noremap = true, silent = true })

-- clear highlights
vim.keymap.set('n', '<Esc>', ':noh<CR>', { desc = 'Clear highlights' })

-- }}}
-- plugins {{{

require('lazy').setup('plugins')

-- }}}
