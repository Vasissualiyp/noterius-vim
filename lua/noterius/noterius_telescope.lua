local M = {}

M.notes_dir = "~/research/notes" -- Default path, can be overridden in init.lua

function M.search_notes()
  require('telescope.builtin').find_files({
    search_dirs = {M.notes_dir},
    find_command = {'rg', '--files', '--type', 'tex', '--glob', '*.tex'},
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#M.notes_dir + 2)
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

function M.grep_notes()
  require('telescope.builtin').live_grep({
    search_dirs = {M.notes_dir},
    additional_args = function(opts)
      return {"--glob", "*.tex"}
    end,
    path_display = function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      local relative_path = path:sub(#M.notes_dir + 2)
      return string.gsub(relative_path, "(.*/)(%d+/%d+/%d+)/(.*)", "%2/" .. tail)
    end,
  })
end

return M
