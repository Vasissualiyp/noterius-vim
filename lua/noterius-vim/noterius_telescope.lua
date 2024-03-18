local M = {}

M.notes_dir = vim.fn.stdpath('data') .. '/home/vasilii/research/notes' -- Default path

function M.setup(opts)
  opts = opts or {}
  M.notes_dir = opts.notes_dir or M.notes_dir
end

function M.search_notes()
  require('telescope.builtin').find_files({
    search_dirs = {M.notes_dir},
    find_command = {'rg', '--files', '--type', 'tex', '--glob', '*.tex'},
    path_display = {"tail"}
  })
end

function M.grep_notes()
  require('telescope.builtin').live_grep({
    search_dirs = {M.notes_dir},
    additional_args = function(opts)
      return {"--glob", "*.tex"}
    end,
    path_display = {"tail"}
  })
end

return M
