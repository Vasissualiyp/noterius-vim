local M = {}

M.notes_dir = vim.fn.stdpath('data') .. '/noterius/notes' -- Default path, can be customized

function M.setup(opts)
  M.notes_dir = opts.notes_dir or M.notes_dir

  local set_keymap = vim.api.nvim_set_keymap
  local opts = {noremap = true, silent = true}

  if opts.keymaps then
    for key, func in pairs(opts.keymaps) do
      if func == "search_notes" then
        set_keymap("n", key, ":lua require('noterius.telescope_integration').search_notes()<CR>", opts)
      elseif func == "grep_notes" then
        set_keymap("n", key, ":lua require('noterius.telescope_integration').grep_notes()<CR>", opts)
      end
    end
  end
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
