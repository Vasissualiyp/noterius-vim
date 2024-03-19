" noterius.vim
" Maintainer: Vasissualiyp
" Version: 0.1

let g:noterius_quickhelp_path = '/home/vasilii/Software/Noterius/templates/quickhelp.tex'
local default_notes_path = '~/research/notes'

if exists('g:noterius_notes_dir')
    let notes_dir = g:noterius_notes_dir
else
    let notes_dir = default_notes_path
endif


command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
