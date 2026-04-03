return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {
    auto_refresh = true,
    warn_no_results = false,
    follow = false,
    focus = true,
    keys = {
      ['<ESC>'] = 'close',
      ['<CR>'] = 'jump_close',
      ['j'] = 'next',
      ['k'] = 'prev'
    },
  },
  config = function(_, opts)
    require('trouble').setup(opts)
    vim.api.nvim_create_autocmd('WinLeave', {
      callback = function()
        if vim.bo.filetype == 'trouble' then
          require('trouble').close()
        end
      end,
    })
  end,
}
