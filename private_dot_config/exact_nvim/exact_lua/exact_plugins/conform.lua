return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = function()
    local formatters_by_ft = {}
    local lsp_path = vim.fn.stdpath('config') .. '/lua/lsp'
    if vim.fn.isdirectory(lsp_path) == 1 then
      ---@diagnostic disable-next-line: param-type-mismatch
      for _, file in ipairs(vim.fn.readdir(lsp_path, [[v:val =~ '\.lua$']])) do
        local name = file:gsub('%.lua$', '')
        local module = require('lsp.' .. name)
        if
          module.formatter
          and module.formatter.package
          and module.lsp
          and module.lsp.config
          and module.lsp.config.filetypes
        then
          for _, ft in ipairs(module.lsp.config.filetypes) do
            formatters_by_ft[ft] = { module.formatter.name or module.formatter.package }
          end
        end
      end
    end

    return {
      formatters_by_ft = formatters_by_ft,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
    }
  end,
}
