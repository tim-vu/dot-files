-- bootstrap {{{

_G.dd = function(...)
  Snacks.debug.inspect(...)
end

vim.loader.enable()

vim.env.PATH = table.concat({
  vim.fn.expand('$HOME/.local/bin'),
  vim.fn.expand('$HOME/.dotnet'),
  vim.env.PATH,
}, ':')

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
-- }}}
-- options {{{

local o = vim.o
local opt = vim.opt
local g = vim.g

-- general
g.mapleader = ' '
opt.undofile = true -- enable persistent undo
opt.backup = false -- disable backup
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.iskeyword = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part, default "@,48-57,_,192-255"
opt.termguicolors = true
opt.swapfile = false
o.shell = 'zsh'

-- ui
opt.winborder = 'rounded'
opt.pumblend = 15
opt.cursorline = true -- highlight the text line of the cursor
opt.number = true -- show numberline
opt.relativenumber = true -- show relative numberline
opt.signcolumn = 'yes' -- always show the sign column

-- wrapping
opt.wrap = true -- soft wrap lines
opt.showbreak = '↪ '
opt.breakindent = true -- make wrapped lines continue visually indented

-- special UI symbols
opt.list = true -- show invisible characters.
opt.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> ,trail:·'
opt.fillchars = 'eob: ,fold:┄,foldclose:,foldopen:'

-- statusline
opt.laststatus = 0 -- never a statusline
opt.ruler = false -- no position info at cmdline
opt.showmode = false -- disable showing modes in command line since it's already in the status line

-- splitting
opt.splitbelow = true -- splitting a new window below the current one
opt.splitright = true -- splitting a new window at the right of the current one
opt.splitkeep = 'screen'

-- scrolling
opt.scrolloff = 15 -- minimum number of lines to keep above and below the cursor.

-- editing
opt.updatetime = 200 -- length of time to wait before triggering the plugin
opt.timeoutlen = 250 -- shorten key timeout length for which-key
opt.inccommand = 'split' -- preview substitutions live

-- indenting
opt.expandtab = true -- convert tabs to spaces
opt.shiftwidth = 4 -- number of space inserted for indentation
opt.softtabstop = 4 -- number of spaces that a <Tab> counts for.
opt.tabstop = 4 -- number of space in a tab
opt.smartindent = true -- do smart auto indenting.

-- searching
opt.ignorecase = true -- ignore case during search
opt.smartcase = true -- respect case if search pattern has upper case
opt.hlsearch = true -- highlight search results as you type.

-- folding
opt.foldmethod = 'marker'
opt.foldmarker = '{{{,}}}' -- this is the default
opt.foldlevel = 0 -- start with all folds closed
opt.foldlevelstart = 0 -- open files with folds closed

-- clipboard
vim.schedule(function() -- to avoid increasing startup-time
  opt.clipboard = 'unnamedplus' -- connection to the system clipboard
end)

-- disable some default providers
g.loaded_node_provider = 1
g.loaded_python3_provider = 1
g.loaded_perl_provider = 1
g.loaded_ruby_provider = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

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

--vim.keymap.set('n', '<Esc>', function()
--  for _, win in ipairs(vim.api.nvim_list_wins()) do
--    local config = vim.api.nvim_win_get_config(win)
--    if config.relative ~= '' then
--      vim.api.nvim_win_close(win, false)
--      return
--    end
--  end
--end, { desc = 'Close float', silent = true })

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

-- }}}
-- plugins {{{

require('lazy').setup('plugins')

vim.cmd([[colorscheme kanagawa-dragon]])

-- }}}
