return {
  'GustavEikaas/easy-dotnet.nvim',
  cmd = 'Dotnet',
  event = {
    'BufReadPre *.cs',
    'BufNewFile *.cs',
    'BufReadPre *.csproj',
    'BufNewFile *.csproj',
    'BufReadPre *.fsproj',
    'BufNewFile *.fsproj',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
  },
  config = function()
    require('easy-dotnet').setup({
      lsp = {
        restart_roslyn_on_branch_change = true,
      },
      auto_bootstrap_namespace = {
        type = 'file_scoped',
      },
      notifications = {
        handler = false,
      },
      diagnostics = {
        default_severity = 'warning',
        setqflist = true,
      },
    })
  end,
}
