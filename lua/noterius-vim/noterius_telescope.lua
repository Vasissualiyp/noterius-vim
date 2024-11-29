local M = {}
local default_notes_path = vim.fn.expand('~/research/notes')

M.notes_dir = vim.g.noterius_notes_dir or default_notes_path

function M.setup(opts)
  opts = opts or {}
  M.notes_dir = opts.notes_dir or M.notes_dir
end

-- Function for live grep in notes
function M.grep_notes()
  if vim.fn.isdirectory(M.notes_dir) == 0 then
    vim.notify("Notes directory does not exist: " .. M.notes_dir, vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').live_grep({
    search_dirs = { M.notes_dir },
    additional_args = function(opts)
      return { "--glob", "*.tex" }
    end,
    path_display = function(opts, path)
      if not path then return '' end
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#M.notes_dir + 2)
      -- Ensure only the first return value is returned
      local formatted_path = string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
      return formatted_path
    end,
  })
end

-- Function for finding files in notes
function M.search_notes()
  if vim.fn.isdirectory(M.notes_dir) == 0 then
    vim.notify("Notes directory does not exist: " .. M.notes_dir, vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').find_files({
    search_dirs = { M.notes_dir },
    find_command = { 'rg', '--files', '--type', 'tex', '--glob', '*.tex' },
    path_display = function(opts, path)
      if not path then return '' end
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#M.notes_dir + 2)
      -- Ensure only the first return value is returned
      local formatted_path = string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
      return formatted_path
    end,
  })
end

return M
