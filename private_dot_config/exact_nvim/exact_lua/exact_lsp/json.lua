return {
  lsp = {
    package = 'json-lsp',
    ---@type vim.lsp.Config
    config = {
      cmd = { 'vscode-json-language-server', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      root_markers = { '.git' },
    },
  },
  formatter = {
    package = 'fixjson',
  },
}
