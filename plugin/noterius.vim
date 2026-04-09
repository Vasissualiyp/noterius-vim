" noterius.vim
" Maintainer: Vasissualiyp
" Version: 0.1

function! noterius#InitPaths()
    let default_notes_path = '~/research/test'
	let default_author = 'User'
	let default_citerius_integration = 0
	let default_noterius_github_integration = 0
	let default_citerius_srs_dir = $HOME . '/research/references'
	let default_logseq_enabled = 0
	let default_logseq_dir = '~/Documents/LogSeq/journals'
	let default_logseq_assets_dir = '~/Documents/LogSeq/assets/svg'
	let default_logseq_unified_mode = 0
	let default_logseq_unified_dir = ''

	" Set default values
	let g:noterius_author = exists('g:noterius_author') ? g:noterius_author : default_author
	let g:noterius_notes_dir = exists('g:noterius_notes_dir') ? g:noterius_notes_dir : default_notes_path
	let g:citerius_integration = exists('g:citerius_integration') ? g:citerius_integration : default_citerius_integration
	let g:noterius_github_integration = exists('g:noterius_github_integration') ? g:noterius_github_integration : default_noterius_github_integration
	let g:citerius_src_dir = exists('g:citerius_src_dir') ? g:citerius_src_dir : default_citerius_srs_dir
	let g:noterius_logseq_enabled = exists('g:noterius_logseq_enabled') ? g:noterius_logseq_enabled : default_logseq_enabled
	let g:noterius_logseq_dir = exists('g:noterius_logseq_dir') ? g:noterius_logseq_dir : default_logseq_dir
	let g:noterius_logseq_assets_dir = exists('g:noterius_logseq_assets_dir') ? g:noterius_logseq_assets_dir : default_logseq_assets_dir
	let g:noterius_logseq_unified_mode = exists('g:noterius_logseq_unified_mode') ? g:noterius_logseq_unified_mode : default_logseq_unified_mode
	let g:noterius_logseq_unified_dir = exists('g:noterius_logseq_unified_dir') ? g:noterius_logseq_unified_dir : default_logseq_unified_dir

    let g:noterius_quickhelp_path = expand(g:noterius_notes_dir) . '/templates/quickhelp.tex'
    let g:noterius_notes_template_path = expand(g:noterius_notes_dir) . '/templates/notes_template.tex'
    let g:noterius_header_path = expand(g:noterius_notes_dir) . '/templates/header.tex'

    let g:current_time = strftime('%H:%M')
    let g:current_date = strftime('%Y-%m-%d')
    let g:current_date_dirfmt = strftime('%Y/%m/%d')
    let g:noterius_todays_dir = g:noterius_notes_dir . '/' . g:current_date_dirfmt
    let g:noterius_todays_file = g:noterius_todays_dir . '/notes.tex'

endfunction

" These variables are only relevant for first-time noterius setup
let g:noterius_source_dir = expand('<sfile>:p:h') . '/..'
let g:noterius_templates_dir = expand('<sfile>:p:h') . '/../templates'

command! NoteriusToday call noterius#NoteriusToday()
command! NoteriusCleanup call noterius#NoteriusCleanup()
command! NoteriusGitPush call noterius#NoteriusGitPush()
command! SetupNoteriusNotes call noterius#SetupNoteriusNotes()
command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
command! NoteriusGitPull call noterius#NoteriusSyncWithRemoteRepo(expand(g:noterius_notes_dir))
command! NoteriusLogseqToday call noterius#LogseqToday()
command! NoteriusToggleLayer call noterius#ToggleLayer()
command! NoteriusTodayDual call noterius#NoteriusTodayDual()
