" noterius.vim
" Maintainer: Vasissualiyp
" Version: 0.1

function! noterius#InitPaths()
    let default_notes_path = '~/research/test'
	let default_author = 'User'
	let default_citerius_integration = 0
	let default_citerius_srs_dir = $HOME . '/research/references'

	" Set default values
	let g:noterius_author = exists('g:noterius_author') ? g:noterius_author : default_author
	let g:noterius_notes_dir = exists('g:noterius_notes_dir') ? g:noterius_notes_dir : default_notes_path
	let g:citerius_integration = exists('g:citerius_integration') ? g:citerius_integration : default_citerius_integration
	let g:citerius_src_dir = exists('g:citerius_src_dir') ? g:citerius_src_dir : default_citerius_srs_dir

    let g:noterius_quickhelp_path = expand(g:noterius_notes_dir) . '/templates/quickhelp.tex'
    let g:noterius_notes_template_path = expand(g:noterius_notes_dir) . '/templates/notes_template.tex'
    let g:noterius_header_path = expand(g:noterius_notes_dir) . '/templates/header.tex'

    let g:current_time = strftime('%H:%M')
    let g:current_date = strftime('%Y-%m-%d')
    let g:current_date_dirfmt = strftime('%Y/%m/%d')
    let g:noterius_todays_dir = g:noterius_notes_dir . '/' . g:current_date_dirfmt
    let g:noterius_todays_file = g:noterius_todays_dir . '/notes.tex'
	
	" These variables are only relevant for first-time noterius setup
    let g:noterius_source_dir = expand('<sfile>:p:h') . '/..'
    let g:noterius_templates_dir = expand('<sfile>:p:h') . '/../templates'

endfunction

command! NoteriusToday call noterius#NoteriusToday()
command! SetupNoteriusNotes call noterius#SetupNoteriusNotes()
command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
command! NoteriusGitPull call noterius#NoteriusSyncWithRemoteRepo(expand(g:noterius_notes_dir))
