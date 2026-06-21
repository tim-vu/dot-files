---@diagnostic disable: undefined-field
return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  event = { 'BufReadPost' },
  ---@type nvim_tree.config
  opts = {
    on_attach = function(bufnr)
      local api = require('nvim-tree.api')
      local function opts(desc)
        return { desc = 'Tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
      vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last sibling'))
      vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First sibling'))
      local function edit_or_open()
        local node = api.tree.get_node_under_cursor()
        if node == nil then
          return
        end
        if node.nodes ~= nil and not node.open then
          api.node.open.edit()
        elseif node.nodes == nil then
          api.node.open.edit()
          api.tree.close()
        end
      end
      local function close_directory()
        local node = api.tree.get_node_under_cursor()
        if node == nil then
          return
        end
        if node.nodes ~= nil and node.open then
          api.node.open.edit()
        end
      end
      local function create()
        local node = api.tree.get_node_under_cursor()
        if node == nil then
          return
        end
        local path = node.type == 'directory' and node.absolute_path or vim.fs.dirname(node.absolute_path)
        require('easy-dotnet').create_item(path)
      end
      local function is_absolute_path(path)
        return vim.startswith(path, '/') or path:match('^%a:[/\\]')
      end
      local function rename_node(node, new_path)
        local rename = require('nvim-tree.actions.fs.rename-file')

        rename.rename(node, new_path)
        api.tree.reload()
        api.tree.find_file({ buf = new_path })
      end
      local function rename_relative()
        local node = api.tree.get_node_under_cursor()
        if node == nil or node.absolute_path == nil or node.name == '..' then
          return
        end

        local utils = require('nvim-tree.utils')
        local cwd = vim.fn.getcwd()
        local default_path = utils.path_relative(node.absolute_path, cwd)

        vim.ui.input({
          prompt = 'Rename to ',
          default = default_path,
          completion = 'file',
        }, function(new_path)
          utils.clear_prompt()
          if new_path == nil or new_path == '' then
            return
          end

          if not is_absolute_path(new_path) then
            new_path = utils.path_join({ cwd, new_path })
          end

          rename_node(node, new_path)
        end)
      end
      local function move_relative()
        local node = api.tree.get_node_under_cursor()
        if node == nil or node.absolute_path == nil or node.name == '..' then
          return
        end

        local utils = require('nvim-tree.utils')
        local cwd = vim.fn.getcwd()
        local basename = vim.fn.fnamemodify(node.absolute_path, ':t')
        local parent = vim.fn.fnamemodify(node.absolute_path, ':h')
        local default_path = vim.fs.relpath(cwd, parent) or parent

        if default_path == '.' then
          default_path = './'
        else
          default_path = utils.path_add_trailing(default_path)
        end

        vim.ui.input({
          prompt = 'Move to ',
          default = default_path,
          completion = 'dir',
        }, function(new_path)
          utils.clear_prompt()
          if new_path == nil or new_path == '' then
            return
          end

          if not is_absolute_path(new_path) then
            new_path = utils.path_join({ cwd, new_path })
          end

          new_path = utils.path_join({ new_path, basename })
          rename_node(node, new_path)
        end)
      end
      vim.keymap.set('n', 'l', edit_or_open, opts('Open'))
      vim.keymap.set('n', 'h', close_directory, opts('Close'))
      vim.keymap.set('n', 'p', api.node.navigate.parent, opts('Go to parent'))
      vim.keymap.set('n', 'x', create, opts('Create file'))
      vim.keymap.set('n', 'r', rename_relative, opts('Rename'))
      vim.keymap.set('n', '<C-r>', move_relative, opts('Move'))
      vim.keymap.set('n', '<Esc>', api.tree.close, opts('Close'))
    end,
    hijack_cursor = true,
    sync_root_with_cwd = true,
    reload_on_bufenter = true,
    update_focused_file = { enable = true },
    filters = { git_ignored = true },
    git = {
      enable = true,
      show_on_dirs = true,
    },
    notify = {
      threshold = vim.log.levels.WARN,
    },
  },
  config = function(_, opts)
    vim.api.nvim_set_keymap(
      'n',
      '<leader>t',
      ':NvimTreeToggle<CR>',
      { desc = 'Open tree', noremap = true, silent = true }
    )
    require('nvim-tree').setup(opts)
  end,
}
