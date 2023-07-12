-- Marks, but you can use more than a single letter.

--[[
TODO:
- If a buffer's been been deleted, then delete the marks from that buffer.
- If it can be reopened, do so.
- Integrate with Telescope and the quickfix list.
- Persistence by writing to swap file?
]]

local M = {}


function M.setup()
  M.ns = vim.api.nvim_create_namespace('marker')
  M.bookmarks = {}
end


function M.create_bookmark()
  vim.ui.input({ prompt = 'Bookmark name? ' }, function (name)
    if not name or name == nil then
      return
    end
    if M.bookmarks[name] ~= nil then
      print('Bookmark name already in use.')
      return
    end

    local line, column = unpack(vim.api.nvim_win_get_cursor(0))
    line = line - 1 -- API indexing inconsistencies
    local extmark_id = vim.api.nvim_buf_set_extmark(0, M.ns, line, column,
      { sign_text = '🏳️', ui_watched = true})
    M.bookmarks[name] = {
      bufnr = vim.api.nvim_get_current_buf(),
      -- TODO: If the buf has been closed, use this to reopen it.
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
  vim.ui.select(names, { prompt = 'Choose a bookmark: ' },
  function (choice, _)
    if not choice then return end

    local bookmark = M.bookmarks[choice]
    if not bookmark then return end

    local location = vim.api.nvim_buf_get_extmark_by_id(
      bookmark.bufnr, M.ns, bookmark.extmark_id, {})
    assert(not vim.tbl_isempty(location), 'No bookmark found!')
    vim.api.nvim_win_set_buf(0, bookmark.bufnr)
    vim.api.nvim_win_set_cursor(0, {location[1] + 1, location[2]})
  end)
end


-- TODO: should this delete the mark from the current position?
-- Or should it just delete the selected mark?
-- How should we mass-delete marks? Via quickfix?
function M.del_bookmark()
  local names = {}
  for key, _ in pairs(M.bookmarks) do
    table.insert(names, key)
  end

  vim.ui.select(names, { prompt = 'Delete a bookmark: ' },
  function (choice, _)
    if not choice then
      return
    end
    local bookmark = M.bookmarks[choice]
    assert(vim.api.nvim_buf_del_extmark(bookmark.bufnr, M.ns,
      bookmark.extmark_id), 'Bookmark not found!')
    M.bookmarks[choice] = nil
  end)
end

return M
