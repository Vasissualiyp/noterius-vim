" noterius.vim
" Maintainer: Vasissualiyp
" Version: 0.1

let default_notes_path = '~/research/notes'
if exists('g:noterius_notes_dir')
    let notes_dir = g:noterius_notes_dir
else
    let notes_dir = default_notes_path
endif

let g:noterius_source_dir = expand('<sfile>:p:h') . '/..'
let g:noterius_templates_dir = expand('<sfile>:p:h') . '/../templates'
let g:noterius_quickhelp_path = expand(notes_dir) . '/templates/quickhelp.tex'
let g:noterius_notes_template_path = expand(notes_dir) . '/templates/notes_template.tex'
let g:noterius_header_path = expand(notes_dir) . '/templates/header.tex'

" Define global variables
let g:author = "Vasilii Pustovoit"
let g:citerius_integration = 1 " 1 to enable, 0 to disable
let g:vim_type = "nvim" " or 'vim'

" Directories and paths
let g:script_dir = fnamemodify(expand('<sfile>:p'), ':h')
let g:noterius_src_dir = g:script_dir . '/..'
let g:citerius_src_dir = $HOME . '/research/references'
let g:notes_main_dir = expand(notes_dir)
let g:templates_src_dir = g:notes_main_dir . '/templates'
let g:template_path = g:templates_src_dir . '/notes_template.tex'

" Get the current time and date
let g:current_time = strftime('%H:%M')
let g:current_date = strftime('%Y-%m-%d')
let g:current_date_dirfmt = strftime('%Y/%m/%d')
let g:dir_path = g:notes_dir . '/' . g:current_date_dirfmt
let g:file_path = g:dir_path . '/notes.tex'

command! NoteriusToday call noterius#NoteriusToday()
command! SetupNoteriusNotes call noterius#SetupNoteriusNotes()
command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
command! NoteriusGitPull call noterius#NoteriusSyncWithRemoteRepo(expand(g:noterius_notes_dir))
