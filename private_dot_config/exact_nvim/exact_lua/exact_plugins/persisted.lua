local function session_progress(message, wait)
  local handle = require('fidget.progress').handle.create({
    title = 'Session',
    message = message,
    lsp_client = { name = 'persisted.nvim' },
  })

  if wait then
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistedLoadPost',
      once = true,
      callback = function()
        handle:finish()
      end,
    })
  else
    handle:finish()
  end
end

local function readable_session(session)
  return session and vim.fn.filereadable(session) ~= 0
end

local function load_session(persisted, message, opts)
  opts = opts or {}

  local session
  if opts.last then
    session = persisted.last()
  elseif opts.session then
    session = opts.session
  else
    session = persisted.current()
    if not readable_session(session) then
      session = persisted.current({ branch = false })
    end
  end

  session_progress(message, readable_session(session))
  persisted.load(opts)
end

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
  keys = {
    {
      '<leader>fs',
      function()
        local persisted = require('persisted')

        persisted.handle_selected({
          prompt = 'Load session: ',
          handler = function(item)
            vim.fn.chdir(item.dir)
            load_session(persisted, 'Loading selected session', { session = item.session })
            persisted.start()
          end,
        })
      end,
      desc = '[F]ind [S]essions',
    },
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
          load_session(persisted, 'Loading last session', { last = true })
          persisted.start()
        elseif argc == 1 then
          local arg = vim.fn.argv(0)
          ---@diagnostic disable-next-line: param-type-mismatch
          if vim.fn.isdirectory(arg) == 1 then
            vim.cmd.cd(arg)
            load_session(persisted, 'Loading directory session')
            persisted.start()
          else
            session_progress('Single file mode, no session')
          end
        end
      end,
      nested = true,
    })

    local file_types = {
      codecompanion = true,
      codecompanion_input = true,
      NvimTree = true,
      terminal = true,
    }

    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistedSavePre',
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local should_delete = vim.api.nvim_buf_is_valid(buf) and file_types[vim.bo[buf].filetype]

          if should_delete then
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
