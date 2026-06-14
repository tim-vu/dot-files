--- @type snacks.Config
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = true,
  ---@type snacks.Config
  opts = {
    notifier = {},
    picker = {
      show_empty = true,
      enabled = true,
      ui_select = true,
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
        codecompanion_actions = {
          layout = {
            box = 'vertical',
            backdrop = false,
            width = 58,
            height = 11,
            border = 'none',
            { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
            { win = 'list', border = 'rounded' },
          },
        },
      },
      config = function(opts)
        if opts.title == 'CodeCompanion actions' then
          opts.layout = { preset = 'codecompanion_actions' }
        end
        return opts
      end,
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
  },
  keys = {
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
}
