return {
  lsp = {
    name = 'gh_actions_ls',
    package = 'gh-actions-language-server',
    ---@type vim.lsp.Config
    config = {
      cmd = { 'gh-actions-language-server', '--stdio' },
      filetypes = { 'yaml' },
      root_dir = function(bufnr, on_dir)
        local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
        if vim.endswith(parent, '/.github/workflows') then
          on_dir(parent)
        end
      end,
      handlers = {
        ['actions/readFile'] = function(_, result)
          if type(result.path) ~= 'string' then
            return nil, nil
          end

          local file_path = vim.uri_to_fname(result.path)
          if vim.fn.filereadable(file_path) ~= 1 then
            return nil, nil
          end

          local file = assert(io.open(file_path, 'r'))
          local text = file:read('*a')
          file:close()
          return text, nil
        end,
      },
      init_options = {},
      capabilities = {
        workspace = {
          didChangeWorkspaceFolders = {
            dynamicRegistration = true,
          },
        },
      },
    },
  },
}
