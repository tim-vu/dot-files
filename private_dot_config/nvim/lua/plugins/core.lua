return {
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-sleuth' },
  { 'folke/which-key.nvim', opts = {} },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    cmd = 'Trouble',
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', function() require('gitsigns').nav_hunk('next', nil, nil) end, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', function() require('gitsigns').nav_hunk('prev', nil, nil) end, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
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
}
