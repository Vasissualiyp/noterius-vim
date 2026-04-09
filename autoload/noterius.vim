" -------------------------- NOTE.SH ---------------------------------
" Replace placeholders within the open document
function! noterius#ReplacePlaceholders()
    " Ensure the buffer is modifiable and writable
    setlocal modifiable
    setlocal buftype=

    " Your search and replace operations
    %s/<today>/\=g:current_date/g
    %s/<noterius_src>/\=g:noterius_notes_dir/g
    %s/<author>/\=g:noterius_author/g
    if g:citerius_integration == 1
        %s/<citations_src>/\=g:citerius_src_dir/g
    else
        g/citations_src/d
        g/printbibliography/d
    endif
endfunction

" TimPope's eunich's inspired CopyFile function
function! noterius#CopyFile(src, dst)
  " Check if the source file exists
  if !filereadable(a:src)
    echo "Source file does not exist: " . a:src
    return
  endif

  " Ensure the destination directory exists
  let dst_dir = fnamemodify(a:dst, ':h')
  if !isdirectory(dst_dir)
    call mkdir(dst_dir, "p")
  endif

  " Copy the file
  try
    " Attempt to use Vim's 'writefile' function along with 'readfile' for the copy operation
    let content = readfile(a:src, 'b')
    call writefile(content, a:dst, 'b')
  catch
    echo "Failed to copy file from " . a:src . " to " . a:dst
    return
  endtry

  echo "File copied from " . a:src . " to " . a:dst
endfunction


function! noterius#NoteriusToday()
		
    let l:first_time_flag = 0

    " Copy the file from the template if it doesn't exist
    if !filereadable(expand(g:noterius_todays_file))
		let l:first_time_flag = 1
        " Check if the directory exists and create it if not
        if !isdirectory(g:noterius_todays_dir)
            call mkdir(g:noterius_todays_dir, "p")
        endif
        
	    call noterius#CopyFile(expand(g:noterius_notes_template_path), expand(g:noterius_todays_file))
    endif

    execute 'edit ' . g:noterius_todays_file

	" Perform necessary replacements if the file doesn't exist
    if l:first_time_flag == 1
        " Call the function to perform replacements
        call noterius#ReplacePlaceholders()
        write
    endif

	" This is needed to allow the compilation of the document
	execute 'VimtexReloadState' 
endfunction

" -------------------------- CLEANUP ---------------------------------
function! noterius#NoteriusCleanup()
    execute '! ' . shellescape(g:noterius_source_dir) . '/bin/cleanup.sh ' . shellescape(expand(g:noterius_notes_dir))
endfunction
" -------------------------- GIT PUSH ---------------------------------
function! noterius#NoteriusGitPush()
    execute '! ' . shellescape(g:noterius_source_dir) . '/bin/cleanup.sh ' . shellescape(expand(g:noterius_notes_dir))

    " Build git commit command with Logseq parameters if enabled
    let l:cmd = shellescape(g:noterius_source_dir) . '/bin/git_commit_notes.sh ' .
                \ shellescape(expand(g:noterius_notes_dir)) . ' ' .
                \ shellescape(g:noterius_github_integration)

    if g:noterius_logseq_enabled
        " Determine Logseq directory based on unified mode
        let l:logseq_dir = g:noterius_logseq_unified_mode ? g:noterius_logseq_unified_dir : g:noterius_logseq_dir
        let l:cmd .= ' ' . shellescape(g:noterius_logseq_enabled) . ' ' . shellescape(expand(l:logseq_dir))
    endif

    execute '! ' . l:cmd
endfunction
" -------------------------- SETUP NOTERIUS ---------------------------------

function! noterius#SetupNoteriusNotes()
    " Ensure the global variable for notes directory is defined
    if !exists('g:noterius_notes_dir')
        echo "Noterius notes directory is not set. Please define g:noterius_notes_dir."
        return
    endif

    " Expand the user variable to handle paths like '~/notes'
    let notes_dir = expand(g:noterius_notes_dir)
    
    " Check if the directory exists
    if isdirectory(notes_dir)
        echo "Directory already exists. Please clean the directory or choose a different one."
        return
    endif

    " Create the notes directory
    call mkdir(notes_dir, "p")
    " Define the path to the templates directory within the plugin's directory structure
    "let noterius_templates_dir = expand('<sfile>:p:h') . '/../templates'

    " Initialize a Git repository if .git directory does not exist
    if !isdirectory(notes_dir . '/.git')
        " Change directory to the notes directory
        call system('cd ' . shellescape(notes_dir) . ' && git init')
        " Check if the Git URL is defined
        if exists('g:noterius_git_url')
            let git_url = g:noterius_git_url
            call system('cd ' . shellescape(notes_dir) . ' && git remote add origin ' . shellescape(git_url) . ' && git branch -M main')
			call noterius#NoteriusSyncWithRemoteRepo(notes_dir)
			
        else
            " Copy the templates directory to the notes directory
            " Using system command for copying, adapt if necessary based on your operating system
            echo g:noterius_templates_dir
            call system('cp -r ' . shellescape(g:noterius_templates_dir) . ' ' . shellescape(notes_dir))
            echo "g:noterius_git_url is not defined. Initialized an empty git repository."
        endif
    endif

    echo "Noterius notes setup completed."
endfunction

" -------------------------- GIT PULL ---------------------------------

function! noterius#NoteriusSyncWithRemoteRepo(gitDir)
    " Save the current working directory
    let l:originalDir = getcwd()

    " Change to the directory specified by the function's argument
    execute 'cd' a:gitDir

    " Check if there are any commits in the remote repository
    let l:remoteCommits = system('git ls-remote --heads origin')

    " Check for errors or empty output indicating no commits
    if v:shell_error || empty(l:remoteCommits)
        " No commits in the remote, so proceed to add, commit, and push
        echo "No commits found in remote. Initializing with first commit."

        " Add the templates directory
        call system('git add templates')

        " Commit the changes
        call system('git commit -m "First commit"')

        " Push the commit to the remote repository
        call system('git push -u origin main')
    else
        " Commits exist, so just pull the latest changes
        echo "Commits found in remote. Pulling changes."
        call system('git pull origin main')
    endif

    " Change back to the original directory
    execute 'cd' l:originalDir
endfunction

" -------------------------- NOTES NAVIGATION ---------------------------------

" Expose the function as a command
function! noterius#FindNextNote()
    let l:filepath = expand("%:p")
    let l:dirs = split(l:filepath, "/")

    let l:year = str2nr(l:dirs[-4])
    let l:month = str2nr(l:dirs[-3])
    let l:day = str2nr(l:dirs[-2])

    " Construct the base directory path without the date parts
    let l:basepath = join(l:dirs[0:-5], "/")

    let l:found = 0
    let l:max_iterations = 365  " One year as the maximum loop count

    while l:found == 0 && l:max_iterations > 0
        let l:day += 1

        if l:day > 31 || (l:month == 2 && l:day > 29) || ((l:month == 4 || l:month == 6 || l:month == 9 || l:month == 11) && l:day > 30)
            let l:day = 1
            let l:month += 1
        endif

        if l:month > 12
            let l:month = 1
            let l:year += 1
        endif

	let l:newpath = "/" . l:basepath . "/" . printf("%04d", l:year) . "/" . printf("%02d", l:month) . "/" . printf("%02d", l:day) . "/notes.tex"

	let is_readable = filereadable(l:newpath)
        if is_readable
            let l:found = 1
            execute "e " . l:newpath
				    silent! execute "normal! ggjVGkkzo"
        endif

        let l:max_iterations -= 1
    endwhile
    " Debug statement
    if l:max_iterations == 0
        echom "No notes found for the next 365 days"
    endif
endfunction

function! noterius#FindPreviousNote()
    let l:filepath = expand("%:p")
    let l:dirs = split(l:filepath, "/")

    let l:year = str2nr(l:dirs[-4])
    let l:month = str2nr(l:dirs[-3])
    let l:day = str2nr(l:dirs[-2])

    " Construct the base directory path without the date parts
    let l:basepath = join(l:dirs[0:-5], "/")

    let l:found = 0
    let l:max_iterations = 365  " One year as the maximum loop count

    while l:found == 0 && l:max_iterations > 0
        let l:day -= 1

        " Check if we need to decrement the month
        if l:day < 1
            let l:month -= 1
            if l:month == 2
                let l:day = 28  " Assuming non-leap year for simplicity
            elseif l:month == 4 || l:month == 6 || l:month == 9 || l:month == 11
                let l:day = 30
            else
                let l:day = 31
            endif
        endif

        " Check if we need to decrement the year
        if l:month < 1
            let l:month = 12
            let l:year -= 1
        endif

        let l:newpath = "/" . l:basepath . "/" . printf("%04d", l:year) . "/" . printf("%02d", l:month) . "/" . printf("%02d", l:day) . "/notes.tex"

        let is_readable = filereadable(l:newpath)
        if is_readable
            let l:found = 1
            execute "e " . l:newpath
				    silent! execute "normal! ggjVGkkzo"
        endif

        let l:max_iterations -= 1
    endwhile
endfunction

" -------------------------- OPEN NOTE BY DATE ---------------------------------

function! noterius#OpenNoteByDate()
    " Prompt the user for input
    let l:input = input('Enter date (YYYY-MM-DD) or day of the week (e.g., Mon, Tue, etc.), or press Enter for today: ')

    " Define the base path of your notes, expanding the ~ to the home directory
    let l:basepath = expand("~/research/notes")

    " Check if the input is empty, and set to today's date if it is
    if l:input == ''
        let l:date = strftime('%Y-%m-%d')
    else
        " Define an associative array for days of the week
        let l:daysOfWeek = {'sun': 0, 'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6}
        let l:dayInput = tolower(l:input)

        " Check if input is a day of the week
        if has_key(l:daysOfWeek, l:dayInput)
            " Perform day of the week calculation
            let l:currentDayOfWeek = strftime('%w')
            let l:targetDayOfWeek = l:daysOfWeek[l:dayInput]
            let l:dayDifference = l:currentDayOfWeek - l:targetDayOfWeek
            if l:dayDifference < 0
                let l:dayDifference += 7
            endif

            let l:secondsPerDay = 24 * 60 * 60
            let l:targetTimestamp = localtime() - l:dayDifference * l:secondsPerDay
            let l:date = strftime('%Y-%m-%d', l:targetTimestamp)

        elseif l:input =~ '\v^\d{4}-\d{2}-\d{2}$'
            " If input matches date format, use it directly
            let l:date = l:input

        else
            echo "Invalid input. Please enter a valid date (YYYY-MM-DD) or day of the week (e.g., Mon, Tue, etc.)."
            return
        endif
    endif

    " Extract year, month, and day from the date
    let l:year = matchstr(l:date, '\v^\d{4}')
    let l:month = matchstr(l:date, '\v\d{2}', 5)
    let l:day = matchstr(l:date, '\v\d{2}$')

    " Construct the file path based on the input date
    let l:newpath = l:basepath . "/" . l:year . "/" . l:month . "/" . l:day . "/notes.tex"

    " Check if the file exists and is readable
    if filereadable(l:newpath)
        execute "edit " . l:newpath
				silent! execute "normal! ggjVGkkzo"
    else
        echo "No note found for " . l:date
    endif
endfunction

" -------------------------- QUICKHELP ---------------------------------

function! noterius#DisplayNoteriusQuickhelp()
    let l:quickhelp_path = get(g:, 'noterius_quickhelp_path', '')
    if l:quickhelp_path == ''
        echo "No path set for Noterius Quickhelp"
        return
    endif

    let l:lines = readfile(l:quickhelp_path)
    if empty(l:lines)
        echo "Failed to read Noterius Quickhelp file or file is empty"
        return
    endif

    tabnew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    call append(0, l:lines)
    setlocal nomodifiable
endfunction

" -------------------------- LOGSEQ INTEGRATION ---------------------------------

" Path computation functions
function! noterius#GetLogseqPath(year, month, day)
    if !g:noterius_logseq_enabled
        return ''
    endif

    let l:base_dir = g:noterius_logseq_unified_mode ? expand(g:noterius_logseq_unified_dir) : expand(g:noterius_logseq_dir)
    let l:filename = printf('%04d_%02d_%02d.md', a:year, a:month, a:day)
    return l:base_dir . '/' . l:filename
endfunction

function! noterius#GetLogseqTodayPath()
    let l:year = str2nr(strftime('%Y'))
    let l:month = str2nr(strftime('%m'))
    let l:day = str2nr(strftime('%d'))
    return noterius#GetLogseqPath(l:year, l:month, l:day)
endfunction

" Date formatting function
function! noterius#FormatLogseqDisplayDate(year, month, day)
    let l:month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    let l:month_name = l:month_names[a:month - 1]

    " Determine the ordinal suffix
    let l:suffix = 'th'
    if a:day == 1 || a:day == 21 || a:day == 31
        let l:suffix = 'st'
    elseif a:day == 2 || a:day == 22
        let l:suffix = 'nd'
    elseif a:day == 3 || a:day == 23
        let l:suffix = 'rd'
    endif

    return l:month_name . ' ' . a:day . l:suffix . ', ' . a:year
endfunction

" Content detection function
function! noterius#IsLogseqEntryEmpty(logseq_path)
    if !filereadable(a:logseq_path)
        return 1
    endif

    let l:lines = readfile(a:logseq_path)
    let l:has_content = 0

    for l:line in l:lines
        " Skip empty lines and whitespace
        let l:trimmed = substitute(l:line, '^\s\+\|\s\+$', '', 'g')
        if l:trimmed == ''
            continue
        endif

        " Skip PREV and NEXT links
        if l:trimmed =~# '^-\s*PREV:' || l:trimmed =~# '^-\s*NEXT:'
            continue
        endif

        " If we find any other content, the entry is not empty
        let l:has_content = 1
        break
    endfor

    return !l:has_content
endfunction

" Navigation functions
function! noterius#FindPreviousLogseqEntry(year, month, day)
    let l:year = a:year
    let l:month = a:month
    let l:day = a:day
    let l:max_iterations = 365

    while l:max_iterations > 0
        " Decrement day
        let l:day -= 1

        " Handle month boundaries
        if l:day < 1
            let l:month -= 1
            if l:month == 2
                let l:day = 28
            elseif l:month == 4 || l:month == 6 || l:month == 9 || l:month == 11
                let l:day = 30
            else
                let l:day = 31
            endif
        endif

        " Handle year boundaries
        if l:month < 1
            let l:month = 12
            let l:year -= 1
        endif

        let l:path = noterius#GetLogseqPath(l:year, l:month, l:day)
        if filereadable(l:path) && !noterius#IsLogseqEntryEmpty(l:path)
            return {'year': l:year, 'month': l:month, 'day': l:day}
        endif

        let l:max_iterations -= 1
    endwhile

    return {}
endfunction

function! noterius#FindNextLogseqEntry(year, month, day)
    let l:year = a:year
    let l:month = a:month
    let l:day = a:day
    let l:max_iterations = 365

    while l:max_iterations > 0
        " Increment day
        let l:day += 1

        " Handle month boundaries
        if l:day > 31 || (l:month == 2 && l:day > 29) || ((l:month == 4 || l:month == 6 || l:month == 9 || l:month == 11) && l:day > 30)
            let l:day = 1
            let l:month += 1
        endif

        " Handle year boundaries
        if l:month > 12
            let l:month = 1
            let l:year += 1
        endif

        let l:path = noterius#GetLogseqPath(l:year, l:month, l:day)
        if filereadable(l:path) && !noterius#IsLogseqEntryEmpty(l:path)
            return {'year': l:year, 'month': l:month, 'day': l:day}
        endif

        let l:max_iterations -= 1
    endwhile

    return {}
endfunction

" Link update functions
function! noterius#UpdateNextLink(year, month, day, next_year, next_month, next_day)
    let l:path = noterius#GetLogseqPath(a:year, a:month, a:day)
    if !filereadable(l:path)
        return
    endif

    let l:lines = readfile(l:path)
    let l:next_date = printf('%04d-%02d-%02d', a:next_year, a:next_month, a:next_day)
    let l:next_link = '- NEXT: [[' . l:next_date . ']]'
    let l:found_next = 0

    " Update or add NEXT link
    for l:i in range(len(l:lines))
        if l:lines[l:i] =~# '^-\s*NEXT:'
            let l:lines[l:i] = l:next_link
            let l:found_next = 1
            break
        endif
    endfor

    " If NEXT link wasn't found, add it after PREV link or at the beginning
    if !l:found_next
        let l:insert_index = 0
        for l:i in range(len(l:lines))
            if l:lines[l:i] =~# '^-\s*PREV:'
                let l:insert_index = l:i + 1
                break
            endif
        endfor
        call insert(l:lines, l:next_link, l:insert_index)
    endif

    call writefile(l:lines, l:path)
endfunction

function! noterius#UpdatePrevLink(year, month, day, prev_year, prev_month, prev_day)
    let l:path = noterius#GetLogseqPath(a:year, a:month, a:day)
    if !filereadable(l:path)
        return
    endif

    let l:lines = readfile(l:path)
    let l:prev_date = printf('%04d-%02d-%02d', a:prev_year, a:prev_month, a:prev_day)
    let l:prev_link = '- PREV: [[' . l:prev_date . ']]'
    let l:found_prev = 0

    " Update or add PREV link
    for l:i in range(len(l:lines))
        if l:lines[l:i] =~# '^-\s*PREV:'
            let l:lines[l:i] = l:prev_link
            let l:found_prev = 1
            break
        endif
    endfor

    " If PREV link wasn't found, add it at the beginning
    if !l:found_prev
        call insert(l:lines, l:prev_link, 0)
    endif

    call writefile(l:lines, l:path)
endfunction

function! noterius#UpdateLogseqLatexLink(logseq_path, latex_url)
    if !filereadable(a:logseq_path)
        return
    endif

    let l:lines = readfile(a:logseq_path)
    let l:latex_link = '- ![LaTeX](' . a:latex_url . ')'


    let l:has_latex_link = 0

    " Check if LaTeX link already exists
    for l:line in l:lines
        if l:line =~# '^-\s*!\[LaTeX\]'
            let l:has_latex_link = 1
            break
        endif
    endfor

    " Add LaTeX link if missing (after PREV/NEXT links)
    if !l:has_latex_link
        let l:insert_index = 0
        for l:i in range(len(l:lines))
            if l:lines[l:i] =~# '^-\s*NEXT:'
                let l:insert_index = l:i + 1
                break
            elseif l:lines[l:i] =~# '^-\s*PREV:'
                let l:insert_index = l:i + 1
            endif
        endfor
        call insert(l:lines, l:latex_link, l:insert_index)
        call writefile(l:lines, a:logseq_path)
    endif
endfunction

" Logseq file creation functions
function! noterius#CreateLogseqFile(year, month, day, latex_file)
    if !g:noterius_logseq_enabled
        return
    endif

    let l:logseq_path = noterius#GetLogseqPath(a:year, a:month, a:day)
    let l:logseq_dir = fnamemodify(l:logseq_path, ':h')

    " Ensure directory exists
    if !isdirectory(l:logseq_dir)
        call mkdir(l:logseq_dir, 'p')
    endif

    " Initialize content array
    let l:content = []

    " Find previous entry
    let l:prev_entry = noterius#FindPreviousLogseqEntry(a:year, a:month, a:day)
    if !empty(l:prev_entry)
        let l:prev_date = printf('%04d-%02d-%02d', l:prev_entry.year, l:prev_entry.month, l:prev_entry.day)
        call add(l:content, '- PREV: [[' . l:prev_date . ']]')
        " Update the previous entry's NEXT link to point to this entry
        call noterius#UpdateNextLink(l:prev_entry.year, l:prev_entry.month, l:prev_entry.day, a:year, a:month, a:day)
    endif

    " Find next entry
    let l:next_entry = noterius#FindNextLogseqEntry(a:year, a:month, a:day)
    if !empty(l:next_entry)
        let l:next_date = printf('%04d-%02d-%02d', l:next_entry.year, l:next_entry.month, l:next_entry.day)
        call add(l:content, '- NEXT: [[' . l:next_date . ']]')
        " Update the next entry's PREV link to point to this entry
        call noterius#UpdatePrevLink(l:next_entry.year, l:next_entry.month, l:next_entry.day, a:year, a:month, a:day)
    endif

    " Add LaTeX link if latex_file is provided
    if a:latex_file != ''
        let l:pdf_path = substitute(expand(a:latex_file), '\.tex$', '.pdf', '')
        call add(l:content, '- ![LaTeX](' . l:pdf_path . ')')
    endif

    " Write the file
    call writefile(l:content, l:logseq_path)

    " Link handwritten notes if they exist
    call noterius#LinkHandwrittenNotes(l:logseq_path, a:year, a:month, a:day)
endfunction

function! noterius#CreateOrUpdateLogseqEntry(year, month, day, latex_file)
    if !g:noterius_logseq_enabled
        return
    endif

    let l:logseq_path = noterius#GetLogseqPath(a:year, a:month, a:day)

    if filereadable(l:logseq_path)
        " File exists, update LaTeX link and handwritten notes
        let l:pdf_path = substitute(expand(a:latex_file), '\.tex$', '.pdf', '')
        call noterius#UpdateLogseqLatexLink(l:logseq_path, l:pdf_path)
        call noterius#LinkHandwrittenNotes(l:logseq_path, a:year, a:month, a:day)
    else
        " File doesn't exist, create it
        call noterius#CreateLogseqFile(a:year, a:month, a:day, a:latex_file)
    endif
endfunction

" Handwritten notes linking function
function! noterius#LinkHandwrittenNotes(logseq_path, year, month, day)
    if !g:noterius_logseq_enabled
        return
    endif

    " Construct path to handwritten notes
    let l:assets_dir = expand(g:noterius_logseq_assets_dir)
    let l:handwritten_dir = l:assets_dir . '/' . printf('%04d/%02d/%02d', a:year, a:month, a:day)

    " Check if directory exists
    if !isdirectory(l:handwritten_dir)
        return
    endif

    " Find all SVG files in the directory
    let l:svg_files = glob(l:handwritten_dir . '/*.svg', 0, 1)
    if empty(l:svg_files)
        return
    endif

    " Read the current logseq file
    let l:lines = readfile(a:logseq_path)

    " Check if handwritten notes section already exists
    let l:has_handwritten_section = 0
    for l:line in l:lines
        if l:line =~# '^- ## Handwritten Notes'
            let l:has_handwritten_section = 1
            break
        endif
    endfor

    " If section doesn't exist, add it
    if !l:has_handwritten_section
        " Add blank line before section if file has content
        if len(l:lines) > 0
            call add(l:lines, '')
        endif
        call add(l:lines, '- ## Handwritten Notes')

        " Add each SVG file
        for l:svg_file in l:svg_files
            let l:filename = fnamemodify(l:svg_file, ':t')
            let l:relative_path = '../assets/svg/' . printf('%04d/%02d/%02d/', a:year, a:month, a:day) . l:filename
            call add(l:lines, '- ![](' . l:relative_path . '){:width 600}')
        endfor

        " Write back to file
        call writefile(l:lines, a:logseq_path)
    endif
endfunction

" User command functions
function! noterius#LogseqToday()
    if !g:noterius_logseq_enabled
        echo "Logseq integration is not enabled. Set g:noterius_logseq_enabled = 1"
        return
    endif

    let l:logseq_path = noterius#GetLogseqTodayPath()
    let l:year = str2nr(strftime('%Y'))
    let l:month = str2nr(strftime('%m'))
    let l:day = str2nr(strftime('%d'))

    " Create or update entry
    call noterius#CreateOrUpdateLogseqEntry(l:year, l:month, l:day, g:noterius_todays_file)

    " Open the file
    execute 'edit ' . l:logseq_path
endfunction

function! noterius#ToggleLayer()
    if !g:noterius_logseq_enabled
        echo "Logseq integration is not enabled. Set g:noterius_logseq_enabled = 1"
        return
    endif

    let l:current_file = expand('%:p')
    let l:extension = expand('%:e')

    if l:extension == 'tex'
        " Extract date from LaTeX path (format: .../YYYY/MM/DD/notes.tex)
        let l:filepath = expand("%:p")
        let l:dirs = split(l:filepath, "/")

        if len(l:dirs) < 4
            echo "Cannot determine date from current file path"
            return
        endif

        let l:year = str2nr(l:dirs[-4])
        let l:month = str2nr(l:dirs[-3])
        let l:day = str2nr(l:dirs[-2])

        " Get Logseq path
        let l:logseq_path = noterius#GetLogseqPath(l:year, l:month, l:day)

        " Create or update Logseq entry
        call noterius#CreateOrUpdateLogseqEntry(l:year, l:month, l:day, l:current_file)

        " Open Logseq file
        execute 'edit ' . l:logseq_path

    elseif l:extension == 'md'
        " Extract date from Logseq path (format: YYYY_MM_DD.md)
        let l:filename = expand('%:t:r')
        let l:date_parts = split(l:filename, '_')

        if len(l:date_parts) != 3
            echo "Cannot determine date from current file name"
            return
        endif

        let l:year = str2nr(l:date_parts[0])
        let l:month = str2nr(l:date_parts[1])
        let l:day = str2nr(l:date_parts[2])

        " Construct LaTeX path
        let l:notes_dir = expand(g:noterius_notes_dir)
        let l:latex_path = l:notes_dir . '/' . printf('%04d/%02d/%02d/notes.tex', l:year, l:month, l:day)

        " Check if LaTeX file exists
        if filereadable(l:latex_path)
            execute 'edit ' . l:latex_path
			execute 'VimtexReloadState'
        else
            echo "LaTeX note not found for this date: " . l:latex_path
        endif
    else
        echo "Current file is neither a LaTeX (.tex) nor Logseq (.md) file"
    endif
endfunction

function! noterius#NoteriusTodayDual()
    if !g:noterius_logseq_enabled
        echo "Logseq integration is not enabled. Set g:noterius_logseq_enabled = 1"
        return
    endif

    " First open LaTeX note
    call noterius#NoteriusToday()

    " Then open Logseq in a split
    let l:year = str2nr(strftime('%Y'))
    let l:month = str2nr(strftime('%m'))
    let l:day = str2nr(strftime('%d'))

    " Create or update Logseq entry
    call noterius#CreateOrUpdateLogseqEntry(l:year, l:month, l:day, g:noterius_todays_file)

    " Open Logseq in vertical split
    let l:logseq_path = noterius#GetLogseqTodayPath()
    execute 'vsplit ' . l:logseq_path
endfunction
