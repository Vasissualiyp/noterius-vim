" noterius.vim
" Maintainer: Vasissualiyp
" Version: 0.1

let g:noterius_quickhelp_path = '/home/vasilii/Software/Noterius/templates/quickhelp.tex'

command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
