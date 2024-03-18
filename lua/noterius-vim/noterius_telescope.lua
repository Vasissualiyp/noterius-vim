local M = {}

-- Initialize notes_dir with a default path
M.notes_dir = vim.fn.stdpath('data') .. '~/research/notes'

function M.setup(opts)
  opts = opts or {}
  -- Here we correctly use M.notes_dir to ensure we're modifying the module's field
  M.notes_dir = opts.notes_dir or M.notes_dir
end

-- Function for live grep in notes
function M.grep_notes()
  require('telescope.builtin').live_grep({
    search_dirs = {M.notes_dir}, -- Correctly reference M.notes_dir
    additional_args = function(opts)
      return {"--glob", "*.tex"}
    end,
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      -- Correctly reference M.notes_dir
      local relative_path = path:sub(#M.notes_dir + 2) -- +2 to remove the leading slash and make it relative
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

-- Function for finding files in notes
function M.search_notes()
  require('telescope.builtin').find_files({
    search_dirs = {M.notes_dir}, -- Correctly reference M.notes_dir
    find_command = {'rg', '--files', '--type', 'tex', '--glob', '*.tex'},
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      -- Correctly reference M.notes_dir
      local relative_path = path:sub(#M.notes_dir + 2)
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

return M
