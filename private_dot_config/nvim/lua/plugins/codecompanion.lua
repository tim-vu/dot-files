return {
  'olimorris/codecompanion.nvim',
  version = '^19.0.0',
  cmd = {
    'CodeCompanion',
    'CodeCompanionActions',
    'CodeCompanionChat',
    'CodeCompanionCLI',
    'CodeCompanionCmd',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      ft = { 'codecompanion', 'codecompanion-ui' },
    },
    'ravitemer/codecompanion-history.nvim',
    'mrjones2014/codecompanion-ui.nvim',
  },
  opts = {
    extensions = {
      history = {
        enabled = true,
        opts = {
          auto_generate_title = false,
          picker = 'snacks',
        },
      },
      ui = {
        enabled = true,
        opts = {
          chat = {
            winbar = {
              {
                component = function(chat)
                  local title = chat.title or chat.opts.title
                  return {
                    text = ('󰭹 %s%%<'):format(title or '[No Title]'),
                    hl = 'CcuiTitle',
                  }
                end,
              },
            },
          },
        },
      },
    },
    adapters = {
      acp = {
        codex = function()
          return require('codecompanion.adapters').extend('codex', {
            defaults = {
              auth_method = 'chatgpt',
            },
          })
        end,
      },
    },
    interactions = {
      chat = {
        adapter = 'codex',
        keymaps = {
          change_mode = {
            modes = { n = 'gA' },
            callback = function(chat)
              if not chat.acp_connection then
                return vim.notify('No ACP connection available', vim.log.levels.WARN)
              end

              for _, option in ipairs(chat.acp_connection:get_config_options()) do
                if option.category == 'mode' or option.id == 'mode' then
                  local command =
                    require('codecompanion.interactions.chat.slash_commands.builtin.acp_session_options').new({
                      Chat = chat,
                    })
                  return command:show_values(option)
                end
              end

              vim.notify('No ACP mode options available', vim.log.levels.WARN)
            end,
            description = 'Change ACP mode',
          },
        },
      },
    },
    display = {
      action_palette = {
        provider = 'snacks',
      },
      chat = {
        show_header_separator = false,
        separator = '-',
        show_context = false,
        show_token_count = true,
        start_in_insert_mode = true,
        show_tools_processing = false,
        icons = {
          chat_context = ' ',
          chat_fold = ' ',
          tool_pending = '  ',
          tool_in_progress = '  ',
          tool_failure = '  ',
          tool_success = '  ',
        },
        window = {
          layout = 'vertical',
          position = 'right',
          width = 0.4,
          opts = {
            breakindent = true,
            wrap = true,
            number = false,
            relativenumber = false,
            signcolumn = 'no',
            cursorline = false,
          },
        },
      },
    },
  },
  keys = {
    {
      '<C-\\>',
      '<cmd>CodeCompanionChat Toggle<cr>',
      mode = { 'n', 'v', 'i' },
      desc = 'Toggle CodeCompanion chat',
    },
    {
      '<leader>aa',
      '<cmd>CodeCompanionActions<cr>',
      mode = { 'n', 'v' },
      desc = 'CodeCompanion actions',
    },
    {
      '<leader>ai',
      '<cmd>CodeCompanion<cr>',
      mode = { 'n', 'v' },
      desc = 'CodeCompanion inline',
    },
  },
}
