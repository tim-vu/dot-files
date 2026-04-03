return {
  'olimorris/persisted.nvim',
  lazy = false,
  opts = {
    autostart = false,
    autoload = false,
    follow_cwd = true,
    use_git_branch = true,
    save_dir = vim.fn.stdpath('state') .. '/sessions/',
  },
  config = function(_, opts)
    require('persisted').setup(opts)

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

    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistedLoadPre",
      callback = function(session)
        vim.notify('PersistedLoadPre')
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistedSavePre",
      callback = function()
        local api = require('nvim-tree.api')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if api.tree.is_tree_buf(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })
  end
}
