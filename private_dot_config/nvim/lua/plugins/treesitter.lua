local parsers = {
  'bash',
  'c_sharp',
  'css',
  'dockerfile',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'typescript',
  'tsx',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
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
  'markdown',
  'sh',
  'typescript',
  'typescriptreact',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  build = ':TSUpdate',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'master',
    },
  },
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = parsers,
      auto_install = false,
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = 'V',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
        },
      },
    })

    local select = require('nvim-treesitter.textobjects.select')
    local move = require('nvim-treesitter.textobjects.move')

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
