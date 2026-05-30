local parsers = {
  'bash',
  'c_sharp',
  'css',
  'dockerfile',
  'html',
  'javascript',
  'json',
  'lua',
  'typescript',
  'tsx',
  'vim',
  'vimdoc',
  'xml',
}

local filetypes = {
  'bash',
  'cs',
  'css',
  'dockerfile',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'lua',
  'sh',
  'typescript',
  'typescriptreact',
  'vim',
  'vimdoc',
  'xml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'main',
    },
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup()
    require('nvim-treesitter').install(parsers)

    require('nvim-treesitter-textobjects').setup({
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v',
          ['@function.outer'] = 'V',
          ['@class.outer'] = 'V',
        },
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require('nvim-treesitter-textobjects.select')
    local move = require('nvim-treesitter-textobjects.move')

    vim.keymap.set({ 'x', 'o' }, 'aa', function()
      select.select_textobject('@parameter.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'ia', function()
      select.select_textobject('@parameter.inner', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'af', function()
      select.select_textobject('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'if', function()
      select.select_textobject('@function.inner', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'ac', function()
      select.select_textobject('@class.outer', 'textobjects')
    end)
    vim.keymap.set({ 'x', 'o' }, 'ic', function()
      select.select_textobject('@class.inner', 'textobjects')
    end)

    vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
      move.goto_next_start('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
      move.goto_next_start('@class.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
      move.goto_next_end('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
      move.goto_next_end('@class.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
      move.goto_previous_start('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
      move.goto_previous_start('@class.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
      move.goto_previous_end('@function.outer', 'textobjects')
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
      move.goto_previous_end('@class.outer', 'textobjects')
    end)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      pattern = filetypes,
      callback = function(event)
        pcall(vim.treesitter.start, event.buf)
      end,
    })
  end,
}
