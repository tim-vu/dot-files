local servers = {}
local lsp_path = vim.fn.stdpath('config') .. '/lua/lsp'
if vim.fn.isdirectory(lsp_path) == 1 then
  ---@diagnostic disable-next-line: param-type-mismatch
  for _, file in ipairs(vim.fn.readdir(lsp_path, [[v:val =~ '\.lua$']])) do
    local name = file:gsub('%.lua$', '')
    servers[name] = require('lsp.' .. name)
  end
end

for name, module in pairs(servers) do
  if module.lsp and module.lsp.config ~= nil then
    local lsp_name = module.lsp.name or name
    vim.lsp.config(lsp_name, module.lsp.config)
    vim.lsp.enable(lsp_name)
  end
end

vim.diagnostic.config({
  virtual_text = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('<leader>fu', function()
      local api = require('trouble')
      api.open({
        mode = 'lsp_references',
        focus = true,
      })
    end, '[F]ind [U]sages')
    map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>jd', vim.lsp.buf.hover, '[J]ava [D]ocs')
    map('<leader>ed', function()
      vim.diagnostic.open_float({ scope = 'cursor' })
    end, '[E]rror [D]ialog')
    map('<leader>el', function()
      local api = require('trouble')
      api.open({
        mode = 'diagnostics',
        filter = { severity = vim.diagnostic.severity.WARN },
      })
    end, '[E]rror [L]ist')
  end,
})

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      { 'Bilal2453/luvit-meta', lazy = true },
    },
    ---@type lazydev.Config
    opts = {
      enabled = true,
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { 'lazy.nvim' },
        { 'lazydev.nvim', words = { 'lazydev' } },
        { 'snacks.nvim', words = { 'snacks', 'Snacks' } },
      },
    },
  },
}
