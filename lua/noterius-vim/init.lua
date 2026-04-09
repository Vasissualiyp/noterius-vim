local M = {}

function M.setup(opts)
  -- Set defaults
  local defaults = {
    notes_dir = '~/research/notes',
    author = 'User',
    citerius_integration = 0,
    noterius_github_integration = 0,
    citerius_src_dir = vim.fn.expand('$HOME') .. '/research/references',
    logseq_enabled = 0,
    logseq_dir = '~/Documents/LogSeq/journals',
    logseq_assets_dir = '~/Documents/LogSeq/assets/svg',
    logseq_unified_mode = 0,
    logseq_unified_dir = '',
  }

  -- Use options provided by the user, or fallback to defaults
  M.config = vim.tbl_extend('force', defaults, opts or {})

  vim.g.noterius_notes_dir   = vim.fn.expand(M.config.notes_dir)
  vim.g.noterius_author      = M.config.author
  vim.g.citerius_integration = M.config.citerius_integration
  vim.g.noterius_github_integration = M.config.noterius_github_integration
  vim.g.citerius_src_dir     = M.config.citerius_src_dir
  vim.g.noterius_logseq_enabled = M.config.logseq_enabled
  vim.g.noterius_logseq_dir = vim.fn.expand(M.config.logseq_dir)
  vim.g.noterius_logseq_assets_dir = vim.fn.expand(M.config.logseq_assets_dir)
  vim.g.noterius_logseq_unified_mode = M.config.logseq_unified_mode
  vim.g.noterius_logseq_unified_dir = M.config.logseq_unified_dir ~= '' and vim.fn.expand(M.config.logseq_unified_dir) or ''

  -- Example: Autocommand to reload VimTeX or similar actions
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      vim.cmd("call noterius#InitPaths()")
    end,
  })
end

return M
