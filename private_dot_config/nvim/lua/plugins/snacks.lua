return {
  ---@type LazyPlugin
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = true,
    ---@type snacks.Config
    opts = {
      notifier = {},
      picker = {
        show_empty = true,
        enabled = true,
        layouts = {
          find = {
            layout = {
              box = 'vertical',
              backdrop = false,
              row = 1,
              width = 0.5,
              height = 0.9,
              border = 'none',
              { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
              { win = 'list', height = 8, border = 'rounded' },
              { win = 'preview', title = '{preview}', border = 'rounded' },
            },
          },
          code_actions = {
            layout = {
              box = 'vertical',
              backdrop = false,
              relative = 'cursor',
              row = 1,
              width = 60,
              height = 0.4,
              border = 'none',
              { win = 'list', border = 'rounded' },
            },
          },
        },
        layout = {
          preset = 'find',
        },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            },
          },
        },
        kinds = {
          codeaction = {
            layout = { preset = 'code_actions' },
          },
          nested_codeaction = {
            layout = { preset = 'code_actions' },
          },
        },
      },
      indent = { enabled = true },
      terminal = {
        win = {
          position = 'bottom',
          height = 0.4,
          bo = { filetype = 'Terminal' },
        },
      },
    },
    keys = {
      {
        '<leader>x',
        function()
          Snacks.terminal.toggle()
        end,
        desc = 'Toggle Terminal',
      },
      --Picker
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = '[F]ind [F]iles',
      },
      {
        '<leader>fa',
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = '[F]ind [S]ymbols',
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      local function cycle_terminals(direction)
        local terminals = Snacks.terminal.list()
        if #terminals <= 1 then
          return
        end

        table.sort(terminals, function(a, b)
          return a.buf < b.buf
        end)

        local active_idx = nil
        local current_buf = vim.api.nvim_get_current_buf()
        for i, term in ipairs(terminals) do
          if term.buf == current_buf then
            active_idx = i
            break
          end
        end

        if not active_idx then
          return
        end

        local next_idx = active_idx + direction
        if next_idx > #terminals then
          next_idx = 1
        end
        if next_idx < 1 then
          next_idx = #terminals
        end

        terminals[active_idx]:hide()
        terminals[next_idx]:show()
      end

      local function new_terminal()
        local terminals = Snacks.terminal.list()
        local max_id = 0
        for _, term in ipairs(terminals) do
          max_id = math.max(max_id, term.id)
        end
        local current_buf = vim.api.nvim_get_current_buf()
        for _, term in ipairs(terminals) do
          if term.buf == current_buf then
            term:hide()
          end
        end
        Snacks.terminal.toggle(nil, { count = max_id + 1 })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'Terminal',
        callback = function(ctx)
          local map = function(lhs, rhs, desc)
            vim.keymap.set({ 'n', 't' }, lhs, rhs, { buffer = ctx.buf, desc = desc })
          end
          map('<C-w>h', function()
            vim.cmd('stopinsert')
            vim.schedule(function()
              cycle_terminals(-1)
            end)
          end, 'Previous terminal')
          map('<C-w>l', function()
            vim.cmd('stopinsert')
            vim.schedule(function()
              cycle_terminals(1)
            end)
          end, 'Next terminal')
          map('<C-w>n', function()
            vim.cmd('stopinsert')
            vim.schedule(function()
              new_terminal()
            end)
          end, 'New terminal')
        end,
      })
    end,
  },
}
