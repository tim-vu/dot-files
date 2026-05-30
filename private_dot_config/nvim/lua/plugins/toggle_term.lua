local direction = 'horizontal'
local size = 15
local terminals = {}
local current = nil

local function close_current()
  local api = require('toggleterm.terminal')
  local term = api.find(function(t)
    return t:is_open()
  end)

  if term ~= nil then
    term:close()
    return true
  end

  return false
end

local function show_terminal(index)
  local api = require('toggleterm.terminal')
  local term = api.get(terminals[index], true)

  if term == nil then
    return
  end

  term:open()
  current = index
end

local function hide_panel()
  local api = require('toggleterm.terminal')
  local term = api.find(function(t)
    return t:is_open()
  end)
  if term ~= nil then
    term:close()
  end
end

local function new_terminal()
  local api = require('toggleterm.terminal')

  local term =
    api.Terminal:new({ direction = direction, display_name = 'terminal ' .. (#terminals + 1), hidden = true })
  table.insert(terminals, term.id)

  local closed = close_current()

  term:open(size)
  if closed then
    term:set_mode('i')
  end
  current = #terminals
end

local function focus_panel()
  if current == nil then
    new_terminal()
    return
  end

  show_terminal(current)
end

local function select_terminal(offset)
  if #terminals == 0 then
    return
  end

  local new_index = current + offset

  if new_index < 1 or new_index > #terminals then
    return
  end

  close_current()
  show_terminal(new_index)
end

local function on_exit(term)
  local index = nil
  for i, id in ipairs(terminals) do
    if id == term.id then
      index = i
    end
  end

  table.remove(terminals, index)

  if #terminals == 0 then
    current = nil
    return
  end

  show_terminal(math.min(#terminals, index))
end

---@type LazySpec
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<leader>x', focus_panel, desc = 'Terminal panel' },
  },
  ---@type toggleterm.Config
  opts = {
    size = size,
    direction = direction,
    start_in_insert = true,
    persist_size = true,
    close_on_exit = true,
    on_open = function(term)
      vim.keymap.set('n', '<Esc>', hide_panel, { buffer = term.bufnr, desc = 'Hide terminal panel' })
      vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { buffer = term.bufnr, desc = 'Terminal normal mode' })
      vim.keymap.set({ 'n', 't' }, '<C-w>n', new_terminal, { buffer = term.bufnr, desc = 'New terminal' })
      vim.keymap.set({ 'n', 't' }, '<C-w>h', function()
        select_terminal(-1)
      end, { buffer = term.bufnr, desc = 'Previous terminal' })
      vim.keymap.set({ 'n', 't' }, '<C-w>l', function()
        select_terminal(1)
      end, { buffer = term.bufnr, desc = 'Next terminal' })
    end,
    on_exit = on_exit,
    terminal_mappings = false,
  },
}
