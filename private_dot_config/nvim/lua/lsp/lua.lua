local root_markers = {
  '.emmyrc.json',
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

return {
  lsp = {
    name = 'lua_ls',
    package = 'lua-language-server',
    ---@type vim.lsp.Config
    config = {
      cmd = { 'lua-language-server' },
      filetypes = { 'lua' },
      root_markers = root_markers,
    },
  },
  formatter = {
    package = 'stylua',
  },
}
