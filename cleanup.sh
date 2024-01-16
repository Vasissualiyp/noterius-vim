#!/bin/bash

# Define the base directory
base_dir=~/research/notes

# Function to remove notes-related files except for notes.tex
cleanup_notes_files() {
    local dir=$1
    # Loop over files with the base name 'notes', except notes.tex
    for file in "$dir"/notes.*; do
        if [ -f "$file" ] && [ "$file" != "$dir/notes.tex" ]; then
            #echo "Removing notes-related file: $file"
            rm "$file"
        fi
    done
}

check_file() {
    local file=$1
    # Extract content between \begin{document} and \end{document}, excluding specific lines
    content=$(sed -n '/\\begin{document}/, /\\end{document}/{
        /\\begin{document}/d
        /\\end{document}/d
        /\\newpage/d
        /\\section{Footnote}/d
        /\\maketitle/d
        p
    }' "$file")
    #echo "Contents of $file:"
    #echo "$content"
    # Check if content contains non-comment, non-empty lines
		if echo "$content" | grep -qE '^[^%].+$'; then
        return 0 # Content found, don't delete
    else
        return 1 # Only comments or empty lines, delete
    fi
}

# Function to process each day's directory
process_day_dir() {
    local day_dir=$1
    local notes_file="$day_dir/notes.tex"

    # Check if notes file exists
    if [ -f "$notes_file" ]; then
        # Call check_file
        if check_file "$notes_file"; then
            # Cleanup notes-related files
            cleanup_notes_files "$day_dir"
            echo "Cleaning up the build files: $day_dir"
        else
            # Remove the entire directory
            echo "Removing notes directory with only comments or empty lines: $day_dir"
            rm -r "$day_dir"
        fi
    fi
}

# Function to process each month's directory
process_month_dir() {
    local month_dir=$1
    
    # Loop through days
    for day in $(seq -w 1 31); do
        local day_dir="$month_dir/$day"
        if [ -d "$day_dir" ]; then
            process_day_dir "$day_dir"
        fi
    done
}

# Main loop to iterate over years and months
for year in $(seq 2023 $(date +%Y)); do
    year_dir="$base_dir/$year"
    
    if [ -d "$year_dir" ]; then
        for month in $(seq -w 1 12); do
            month_dir="$year_dir/$month"
            
            if [ -d "$month_dir" ]; then
                process_month_dir "$month_dir"
            fi
        done
    fi
done
