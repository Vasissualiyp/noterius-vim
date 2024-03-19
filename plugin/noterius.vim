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

command! SetupNoteriusNotes call noterius#SetupNoteriusNotes()
command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
command! NoteriusGitPull call noterius#NoteriusSyncWithRemoteRepo(expand(g:noterius_notes_dir))
