# Marks, but you can use more than a single letter.

local M = {}

M.ns = vim.api.nvim_create_namespace('marker')
M.bookmarks = {}

function M.create_bookmark()
  vim.ui.input('Bookmark name?', function (name)
    if not name or name == nil then
      return
    end

    local line, column = unpack(vim.api.nvim_win_get_cursor(0))
    line = line - 1 -- API indexing inconsistencies
    local extmark_id = vim.api.nvim_buf_set_extmark(0, M.ns, line, column,
      { sign_text = '🏳️', ui_watched = true})
    M.bookmarks[name] = {
      bufnr = vim.api.nvim_get_current_buf(),
      buf_name = vim.api.nvim_buf_get_name(0),
      extmark_id = extmark_id,
    }
  end)
end

function M.goto_bookmark()
  local names = {}
  for key, _ in pairs(M.bookmarks) do
    table.insert(names, key)
  end
  vim.ui.select(names, { prompt = 'Choose a bookmark:' },
  function (choice, _)
    if not names then
      return
    end

    local bookmark = M.bookmarks[choice]
    local row, col = unpack(vim.api.nvim_buf_get_extmark_by_id(
      bookmark.bufnr, M.ns, bookmark.extmark_id, {}))

    vim.api.nvim_win_set_buf(0, bookmark.bufnr)
    vim.api.nvim_win_set_cursor(0, {row + 1, col})
  end)
end

function M.del_bookmark()
  local names = {}
  for key, _ in pairs(M.bookmarks) do
    table.insert(names, key)
  end

  vim.ui.select(names, { prompt = 'Delete bookmark (empty => current pos)' },
  function (choice, _)
    if not names then
      return
    end

    local bookmark = M.bookmarks[choice]
    local row, col = unpack(vim.api.nvim_buf_get_extmark_by_id(
      bookmark.bufnr, M.ns, bookmark.extmark_id, {}))

    vim.api.nvim_win_set_buf(0, bookmark.bufnr)
    vim.api.nvim_win_set_cursor(0, {row + 1, col})
  end)
end

return M
