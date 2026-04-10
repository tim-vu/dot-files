return {
  { 'tpope/vim-sleuth' },
  { 'folke/which-key.nvim', opts = {} },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_', show_count = true },
        topdelete = { text = '‾', show_count = true },
        changedelete = { text = '~', show_count = true },
        untracked = { text = '┆' },
      },
      signs_staged = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_', show_count = true },
        topdelete = { text = '‾', show_count = true },
        changedelete = { text = '~', show_count = true },
        untracked = { text = '┆' },
      },
      current_line_blame_opts = {
        virt_text_pos = 'overlay',
      },
      on_attach = function(bufnr)
        local api = require('gitsigns')

        vim.keymap.set('n', '<leader>hp', function()
          api.nav_hunk('next', nil, nil)
        end, { buffer = bufnr, desc = '[H]unk [P]revious' })
        vim.keymap.set('n', '<leader>hn', function()
          api.nav_hunk('prev', nil, nil)
        end, { buffer = bufnr, desc = '[H]unk [N]ext' })
        vim.keymap.set('n', '<leader>gb', api.toggle_current_line_blame, { buffer = bufnr, desc = '[G]it [B]lame' })
      end,
    },
  },
  {
    'numToStr/Comment.nvim',
    opts = {
      toggler = { line = '<C-_>' },
      opleader = { line = '<C-_>' },
      mappings = { basic = true, extra = false },
    },
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', '<cmd>Git<cr>', desc = '[G]it Fugitive' },
    },
  },
}
