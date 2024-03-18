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

command! FindPreviousNote call noterius#FindPreviousNote()
command! FindNextNote call noterius#FindNextNote()
command! OpenNoteByDate call noterius#OpenNoteByDate()
command! DisplayNoteriusQuickhelp call noterius#DisplayNoteriusQuickhelp()
