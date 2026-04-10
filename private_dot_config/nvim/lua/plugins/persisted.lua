return {
  'olimorris/persisted.nvim',
  lazy = false,
  opts = {
    autostart = true,
    autoload = false,
    follow_cwd = true,
    use_git_branch = true,
    save_dir = vim.fn.stdpath('state') .. '/sessions/',
    on_autoload_no_session = function()
      vim.cmd('intro')
    end,
  },
  config = function(_, opts)
    require('persisted').setup(opts)

    local is_starting = true
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('persisted_autoload', { clear = true }),
      callback = function()
        if vim.g.started_with_stdin then
          return
        end

        local persisted = require('persisted')
        local argc = vim.fn.argc()

        if argc == 0 then
          persisted.load({ last = true })
          persisted.start()
          vim.notify('Loading last session')
        elseif argc == 1 then
          local arg = vim.fn.argv(0)
          ---@diagnostic disable-next-line: param-type-mismatch
          if vim.fn.isdirectory(arg) == 1 then
            vim.cmd.cd(arg)
            persisted.load()
            persisted.start()
            vim.notify('Loading directory session')
          else
            vim.notify('Single file mode, no session')
          end
        end
      end,
      nested = true,
    })

    local file_types = { NvimTree = true, snacks_terminal = true }
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistedSavePre',
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and file_types[vim.bo[buf].filetype] then
            vim.api.nvim_buf_delete(buf, {
              force = true,
            })
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd('DirChanged', {
      pattern = 'global',
      callback = function()
        vim.schedule(function()
          local persisted = require('persisted')
          persisted.load({ autoload = true })
          persisted.start()
        end)
      end,
    })
  end,
}
