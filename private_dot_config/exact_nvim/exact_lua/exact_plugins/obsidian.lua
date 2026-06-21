vim.opt_local.conceallevel = 2

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = 'personal',
        path = '~/Documents/plans',
      },
    },
  },
}
