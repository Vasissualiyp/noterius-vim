local M = {}
local default_logseq_path = vim.fn.expand('~/Documents/LogSeq/journals')

M.logseq_dir = vim.g.noterius_logseq_dir or default_logseq_path

function M.setup(opts)
  opts = opts or {}
  M.logseq_dir = opts.logseq_dir or M.logseq_dir
end

-- Function to get the logseq directory (handles unified mode)
function M.get_logseq_dir()
  if vim.g.noterius_logseq_unified_mode == 1 and vim.g.noterius_logseq_unified_dir ~= '' then
    return vim.fn.expand(vim.g.noterius_logseq_unified_dir)
  else
    return vim.fn.expand(vim.g.noterius_logseq_dir or default_logseq_path)
  end
end

-- Function to format date display from YYYY_MM_DD.md to DD/MM/YYYY
function M.format_date_display(filename)
  -- Extract date parts from YYYY_MM_DD.md format
  local year, month, day = filename:match("(%d%d%d%d)_(%d%d)_(%d%d)")
  if year and month and day then
    return day .. '/' .. month .. '/' .. year
  end
  return filename
end

-- Function for live grep in Logseq notes
function M.grep_logseq()
  if vim.g.noterius_logseq_enabled ~= 1 then
    vim.notify("Logseq integration is not enabled. Set g:noterius_logseq_enabled = 1", vim.log.levels.ERROR)
    return
  end

  local search_dir = M.get_logseq_dir()

  if vim.fn.isdirectory(search_dir) == 0 then
    vim.notify("Logseq directory does not exist: " .. search_dir, vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').live_grep({
    search_dirs = { search_dir },
    additional_args = function(opts)
      return { "--glob", "*.md" }
    end,
    path_display = function(opts, path)
      if not path then return '' end
      local filename = vim.fn.fnamemodify(path, ':t')
      -- Convert YYYY_MM_DD.md to DD/MM/YYYY
      return M.format_date_display(filename)
    end,
  })
end

-- Function for finding files in Logseq notes
function M.search_logseq()
  if vim.g.noterius_logseq_enabled ~= 1 then
    vim.notify("Logseq integration is not enabled. Set g:noterius_logseq_enabled = 1", vim.log.levels.ERROR)
    return
  end

  local search_dir = M.get_logseq_dir()

  if vim.fn.isdirectory(search_dir) == 0 then
    vim.notify("Logseq directory does not exist: " .. search_dir, vim.log.levels.ERROR)
    return
  end

  require('telescope.builtin').find_files({
    search_dirs = { search_dir },
    find_command = { 'rg', '--files', '--glob', '*.md' },
    path_display = function(opts, path)
      if not path then return '' end
      local filename = vim.fn.fnamemodify(path, ':t')
      -- Convert YYYY_MM_DD.md to DD/MM/YYYY
      return M.format_date_display(filename)
    end,
  })
end

return M
