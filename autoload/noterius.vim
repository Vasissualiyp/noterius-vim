function! SetupNoteriusNotes()
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
			call NoteriusSyncWithRemoteRepo(notes_dir)
			
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

function! NoteriusSyncWithRemoteRepo(gitDir)
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

command! SetupNoteriusNotes call noterius#SetupNoteriusNotes()
command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
command! NoteriusGitPull call noterius#NoteriusSyncWithRemoteRepo(expand(g:noterius_notes_dir))
