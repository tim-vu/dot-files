---@diagnostic disable: undefined-field
return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    opts = {
      overrides = function(colors)
        local theme = colors.theme
        local makeDiagnosticColor = function(color)
          local c = require('kanagawa.lib.color')
          return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
        end
        return {
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },

          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

          DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
          DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
          DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
          DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),

          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency,,
          PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = '#C0A36E' },

          BlinkCmpMenuBorder = { fg = '', bg = '' },
        }
      end,
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local indent = function()
        local space_pat = [[\v^ +]]
        local tab_pat = [[\v^\t+]]
        local space_indent = vim.fn.search(space_pat, 'nwc')
        local tab_indent = vim.fn.search(tab_pat, 'nwc')
        local mixed = (space_indent > 0 and tab_indent > 0)
        local mixed_same_line
        if not mixed then
          mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')
          mixed = mixed_same_line > 0
        end
        if not mixed then
          return ''
        end
        if mixed_same_line ~= nil and mixed_same_line > 0 then
          return 'MI:' .. mixed_same_line
        end
        local space_indent_cnt = vim.fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
        local tab_indent_cnt = vim.fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
        if space_indent_cnt > tab_indent_cnt then
          return 'MI:' .. tab_indent
        else
          return 'MI:' .. space_indent
        end
      end

      local trailing = function()
        local space = vim.fn.search([[\s\+$]], 'nwc')
        return space ~= 0 and 'TW:' .. space or ''
      end

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
      }

      require('lualine').setup({
        options = {
          theme = 'kanagawa',
          globalstatus = true,
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(str)
                return str:sub(1, 1)
              end,
              color = { gui = 'bold' },
              separator = { right = '▓▒░' },
            },
          },
          lualine_b = {
            { 'branch', icon = { '' } },
          },
          lualine_x = {
            { trailing },
            { indent },
            {
              'diff',
              cond = conditions.hide_in_width,
              symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
            {
              'diagnostics',
              cond = conditions.hide_in_width,
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            },
          },
          lualine_y = {
            {
              'lsp_status',
              cond = conditions.hide_in_width,
              icon = ' ',
              show_name = true,
            },
            { 'location', cond = conditions.hide_in_width },
          },
          lualine_z = {
            { 'progress', separator = { left = '░▒▓' } },
          },
        },
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = { 'BufReadPost' },
    ---@type nvim_tree.config
    opts = {
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
          return { desc = 'Tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
        vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last sibling'))
        vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First sibling'))
        local function edit_or_open()
          local node = api.tree.get_node_under_cursor()
          if node == nil then
            return
          end
          if node.nodes ~= nil and not node.open then
            api.node.open.edit()
          elseif node.nodes == nil then
            api.node.open.edit()
            api.tree.close()
          end
        end
        local function close_directory()
          local node = api.tree.get_node_under_cursor()
          if node == nil then
            return
          end
          if node.nodes ~= nil and node.open then
            api.node.open.edit()
          end
        end
        vim.keymap.set('n', 'l', edit_or_open, opts('Open'))
        vim.keymap.set('n', 'h', close_directory, opts('Close'))
        vim.keymap.set('n', 'p', api.node.navigate.parent, opts('Go to parent'))
        vim.keymap.set('n', 'x', api.fs.create, opts('Create file'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
        vim.keymap.set('n', '<Esc>', api.tree.close, opts('Close'))
      end,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      reload_on_bufenter = true,
      update_focused_file = { enable = true },
      filters = { git_ignored = true },
      git = {
        enable = true,
        show_on_dirs = true,
      },
    },
    config = function(_, opts)
      vim.api.nvim_set_keymap(
        'n',
        '<leader>t',
        ':NvimTreeToggle<CR>',
        { desc = 'Open tree', noremap = true, silent = true }
      )
      require('nvim-tree').setup(opts)
      local prev = { new_name = '', old_name = '' } -- Prevents duplicate events
      vim.api.nvim_create_autocmd('User', {
        pattern = 'NvimTreeSetup',
        callback = function()
          local events = require('nvim-tree.api').events
          events.subscribe(events.Event.NodeRenamed, function(data)
            if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
              data = data
              Snacks.rename.on_rename_file(data.old_name, data.new_name)
            end
          end)
        end,
      })
    end,
  },
  { 'typicode/bg.nvim', lazy = false },
}
