return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    opts = {
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)

      local servers = {}
      local lsp_path = vim.fn.stdpath('config') .. '/lua/lsp'
      if vim.fn.isdirectory(lsp_path) == 1 then
        ---@diagnostic disable-next-line: param-type-mismatch
        for _, file in ipairs(vim.fn.readdir(lsp_path, [[v:val =~ '\.lua$']])) do
          local name = file:gsub('%.lua$', '')
          servers[name] = require('lsp.' .. name)
        end
      end

      local ensure_installed = {}
      for _, module in pairs(servers) do
        if module.lsp and module.lsp.package then
          table.insert(ensure_installed, module.lsp.package)
        end
        if module.formatter and module.formatter.package then
          table.insert(ensure_installed, module.formatter.package)
        end
      end

      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
    end,
  },
}
