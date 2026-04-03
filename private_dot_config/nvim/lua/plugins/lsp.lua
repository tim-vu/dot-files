return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      { 'Bilal2453/luvit-meta', lazy = true },
    },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'williamboman/mason.nvim',
    dependencies = {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    opts = {
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)

      local servers = {}
      local lsp_path = vim.fn.stdpath('config') .. '/lua/lsp'
      if vim.fn.isdirectory(lsp_path) == 1 then
      ---@diagnostic disable-next-line: param-type-mismatch
        for _, file in ipairs(vim.fn.readdir(lsp_path, [[v:val =~ '\.lua$']])) do
          local name = file:gsub('%.lua$', '')
          servers[name] = require('lsp.' .. name)
        end
      end

      local ensure_installed = {}
      for _, value in pairs(servers) do
        table.insert(ensure_installed, value.package)
      end

      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      for name, server in pairs(servers) do
        vim.lsp.enable(name)
        if server.config ~= nil then
          vim.lsp.config(name, server.config)
        end
      end

      -- Suppress diagnostics while LSP is still initializing to avoid spurious warnings
      local loading_clients = {} -- { [bufnr] = count of in-flight tokens }
      vim.api.nvim_create_autocmd('LspProgress', {
        group = vim.api.nvim_create_augroup('lsp-progress', { clear = true }),
        callback = function(event)
          local bufnr = vim.api.nvim_get_current_buf()
          local kind = vim.tbl_get(event, 'data', 'params', 'value', 'kind')
          if kind == 'begin' then
            loading_clients[bufnr] = (loading_clients[bufnr] or 0) + 1
            vim.diagnostic.enable(false, { bufnr = bufnr })
          elseif kind == 'end' then
            loading_clients[bufnr] = math.max((loading_clients[bufnr] or 1) - 1, 0)
            if loading_clients[bufnr] == 0 then
              vim.diagnostic.enable(true, { bufnr = bufnr })
            end
          end
        end,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          local function code_action_cursor()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local lnum = cursor[1] - 1
            local col = cursor[2]
            local diagnostics = vim.diagnostic.get(event.buf, { lnum = lnum })
            local cursor_diags = {}
            for _, diag in ipairs(diagnostics) do
              if diag.col <= col and (not diag.end_col or diag.end_col >= col) then
                table.insert(cursor_diags, diag)
              end
            end
            vim.lsp.buf.code_action({ context = { diagnostics = cursor_diags } })
          end

          map('<leader>ca', code_action_cursor, '[C]ode [A]ction')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('<leader>fu', '<cmd>Trouble lsp_references focus=true<cr>', '[F]ind [U]sages')
          map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('<leader>jd', vim.lsp.buf.hover, '[J]ava [D]ocs')
          map('<leader>ed', function() vim.diagnostic.open_float({ scope = 'cursor' }) end, '[E]rror [D]ialog')
        end,
      })
    end,
  },
}
