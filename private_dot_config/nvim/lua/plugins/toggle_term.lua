local height = 15
local terminals = {}
local current = 0
local panel_win = nil
local group = vim.api.nvim_create_augroup('terminal-panel', { clear = true })

local function valid_buffer(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

local function terminal_index(bufnr)
  for index, terminal in ipairs(terminals) do
    if terminal == bufnr then
      return index
    end
  end
end

local function panel_window()
  if panel_win ~= nil and vim.api.nvim_win_is_valid(panel_win) then
    return panel_win
  end

  panel_win = nil
end

local function current_tab_panel()
  local win = panel_window()
  if win ~= nil and vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage() then
    return win
  end
end

local function close_window(win)
  if win == nil or not vim.api.nvim_win_is_valid(win) then
    return
  end

  if win == panel_win then
    panel_win = nil
  end

  local tab = vim.api.nvim_win_get_tabpage(win)
  if #vim.api.nvim_tabpage_list_wins(tab) == 1 then
    vim.api.nvim_win_call(win, function()
      vim.cmd('enew!')
    end)
    return
  end

  vim.api.nvim_win_close(win, true)
end

local function close_panel()
  local win = panel_window()
  if win == nil then
    return
  end

  pcall(vim.cmd, 'stopinsert')
  close_window(win)
end

local function open_panel(bufnr)
  local win = current_tab_panel()

  if win == nil then
    close_panel()
    vim.cmd(('botright %dsplit'):format(height))
    win = vim.api.nvim_get_current_win()
    panel_win = win
  end

  vim.api.nvim_set_current_win(win)
  vim.wo[win].winfixheight = true
  vim.api.nvim_win_set_height(win, height)

  if bufnr ~= nil then
    vim.api.nvim_win_set_buf(win, bufnr)
  end
end

local function panel_has_buffer(bufnr)
  local win = panel_window()
  return win ~= nil and vim.api.nvim_win_get_buf(win) == bufnr
end

local function close_buffer_windows(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    close_window(win)
  end
end

local function enter_terminal(bufnr)
  vim.defer_fn(function()
    if valid_buffer(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
      vim.cmd('startinsert')
    end
  end, 10)
end

local function forget_terminal(index)
  table.remove(terminals, index)

  if #terminals == 0 then
    current = 0
  elseif current == index then
    current = math.min(index, #terminals)
  elseif index < current then
    current = current - 1
  end
end

local function show_terminal(index)
  local bufnr = terminals[index]
  if bufnr == nil then
    return
  end

  if not valid_buffer(bufnr) then
    forget_terminal(index)
    if current > 0 then
      show_terminal(current)
    end
    return
  end

  current = index
  open_panel(bufnr)
  enter_terminal(bufnr)
end

local function select_terminal(offset)
  local index = current + offset
  if index >= 1 and index <= #terminals then
    show_terminal(index)
  end
end

local function new_terminal()
  open_panel()
  vim.cmd('terminal')

  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = 'hide'

  vim.keymap.set('t', '<Esc>', close_panel, { buffer = bufnr, desc = 'Hide terminal panel' })
  vim.keymap.set({ 'n', 't' }, '<C-w>n', new_terminal, { buffer = bufnr, desc = 'New terminal' })
  vim.keymap.set({ 'n', 't' }, '<C-w>h', function()
    select_terminal(-1)
  end, { buffer = bufnr, desc = 'Previous terminal' })
  vim.keymap.set({ 'n', 't' }, '<C-w>l', function()
    select_terminal(1)
  end, { buffer = bufnr, desc = 'Next terminal' })

  table.insert(terminals, bufnr)
  current = #terminals
  enter_terminal(bufnr)
end

local function focus_panel()
  if current == 0 then
    new_terminal()
    return
  end

  show_terminal(current)
end

vim.api.nvim_create_autocmd('TermClose', {
  group = group,
  callback = function(event)
    local index = terminal_index(event.buf)
    if index == nil then
      return
    end

    local show_next = panel_has_buffer(event.buf)
    forget_terminal(index)

    vim.schedule(function()
      if show_next and current > 0 then
        show_terminal(current)
      end

      close_buffer_windows(event.buf)
      if valid_buffer(event.buf) then
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end
    end)
  end,
})

vim.keymap.set('n', '<leader>x', focus_panel, { desc = 'Terminal panel' })

return {}
