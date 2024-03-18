local M = {}

M.notes_dir = vim.fn.stdpath('data') .. '/home/vasilii/research/notes' -- Default path

function M.setup(opts)
  opts = opts or {}
  M.notes_dir = opts.notes_dir or M.notes_dir
end

-- Function for live grep in notes
function M.grep_notes()
  require('telescope.builtin').live_grep({
    search_dirs = {notes_dir},
    additional_args = function(opts)
      return {"--glob", "*.tex"}
    end,
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#notes_dir + 2) -- +2 to remove the leading slash and make it relative
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

-- Function for finding files in notes
function M.find_notes()
  require('telescope.builtin').find_files({
    search_dirs = {notes_dir},
    find_command = {'rg', '--files', '--type', 'tex', '--glob', '*.tex'},
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#notes_dir + 2)
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

return M
