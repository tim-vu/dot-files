return {
  lsp = {
    package = 'marksman',
    ---@type vim.lsp.Config
    config = {
      cmd = { 'marksman', 'server' },
      filetypes = { 'markdown' },
      root_markers = { '.marksman.toml', '.git' },
    },
  },
  formatter = {
    package = 'prettier',
  },
}
