return {
  lsp = {
    package = 'json-lsp',
    ---@type vim.lsp.Config
    config = {
      cmd = { 'vscode-json-languageserver', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      root_markers = { '.git' },
    },
  },
  formatter = {
    package = 'fixjson',
  },
}
