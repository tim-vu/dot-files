---@diagnostic disable: undefined-field
return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    opts = {
      overrides = function(colors)
        local theme = colors.theme
        local c = require('kanagawa.lib.color')
        local makeDiagnosticColor = function(color)
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

          CodeCompanionChatInfo = { fg = theme.diag.info },
          CodeCompanionChatError = { fg = theme.diag.error },
          CodeCompanionChatWarn = { fg = theme.diag.warning },
          CodeCompanionChatSubtext = { fg = theme.syn.comment },
          CodeCompanionChatFold = { fg = theme.syn.comment, italic = true },
          CodeCompanionChatHeader = { fg = theme.syn.fun, bold = true },
          CodeCompanionChatSeparator = { fg = theme.ui.nontext },
          CodeCompanionChatTokens = { fg = theme.syn.comment },
          CodeCompanionChatTool = { fg = theme.syn.special1 },
          CodeCompanionChatToolFailure = { fg = theme.diag.error },
          CodeCompanionChatToolFailureIcon = { fg = theme.diag.error },
          CodeCompanionChatToolGroup = { fg = theme.syn.identifier, bold = true },
          CodeCompanionChatToolInProgress = { fg = theme.diag.info },
          CodeCompanionChatToolInProgressIcon = { fg = theme.diag.info },
          CodeCompanionChatToolPending = { fg = theme.diag.warning },
          CodeCompanionChatToolPendingIcon = { fg = theme.diag.warning },
          CodeCompanionChatToolSuccess = { fg = theme.diag.ok },
          CodeCompanionChatToolSuccessIcon = { fg = theme.diag.ok },
          CodeCompanionChatToolText = { fg = theme.syn.comment },
          CodeCompanionChatEditorContext = { fg = theme.syn.type },
          CodeCompanionDiffAdd = { fg = theme.vcs.added, bg = theme.diff.add },
          CodeCompanionDiffDelete = { fg = theme.vcs.removed, bg = theme.diff.delete },
          CodeCompanionDiffText = { fg = theme.vcs.changed, bg = theme.diff.text },
          CodeCompanionDiffTextDelete = { fg = theme.vcs.removed, bg = theme.diff.delete },
          CodeCompanionDiffBanner = { fg = theme.diag.hint, bold = true },
          CodeCompanionDiffBannerInline = { fg = theme.syn.comment },
          CodeCompanionCLIPath = { fg = theme.syn.preproc },
          CodeCompanionVirtualText = { fg = theme.syn.comment },
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

      local filename = function()
        return vim.fn.expand('%:t')
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
          lualine_c = {
            { filename },
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
    'j-hui/fidget.nvim',
    opts = {
      progress = {
        poll_rate = false,
        clear_on_detach = false,
      },
      notification = {
        window = {
          avoid = { 'NvimTree' },
        },
      },
      integration = {
        ['nvim-tree'] = {
          enable = true,
        },
      },
    },
  },
  { 'typicode/bg.nvim', lazy = false },
}
