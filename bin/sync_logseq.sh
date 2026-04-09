#!/bin/bash

# Logseq Sync Script for Noterius
# Syncs LaTeX notes with Logseq journals, creating bidirectional links

set -e

# Check arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <notes_dir> <logseq_dir> <assets_dir> [unified_mode]"
    echo "Example: $0 ~/research/notes ~/Documents/LogSeq/journals ~/Documents/LogSeq/assets/svg 0"
    exit 1
fi

NOTES_DIR="$1"
LOGSEQ_DIR="$2"
ASSETS_DIR="$3"
UNIFIED_MODE="${4:-0}"

# Expand paths
NOTES_DIR=$(eval echo "$NOTES_DIR")
LOGSEQ_DIR=$(eval echo "$LOGSEQ_DIR")
ASSETS_DIR=$(eval echo "$ASSETS_DIR")

# Verify directories exist
if [ ! -d "$NOTES_DIR" ]; then
    echo "Error: Notes directory does not exist: $NOTES_DIR"
    exit 1
fi

# Create Logseq directory if it doesn't exist
mkdir -p "$LOGSEQ_DIR"

# Function to format display date (e.g., "Apr 9th, 2026")
format_display_date() {
    local year=$1
    local month=$2
    local day=$3

    local month_names=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
    local month_name=${month_names[$((10#$month - 1))]}

    # Determine ordinal suffix
    local suffix="th"
    if [ "$day" = "01" ] || [ "$day" = "21" ] || [ "$day" = "31" ]; then
        suffix="st"
    elif [ "$day" = "02" ] || [ "$day" = "22" ]; then
        suffix="nd"
    elif [ "$day" = "03" ] || [ "$day" = "23" ]; then
        suffix="rd"
    fi

    # Remove leading zero from day
    local day_num=$((10#$day))

    echo "${month_name} ${day_num}${suffix}, ${year}"
}

# Function to check if Logseq entry is empty (only has PREV/NEXT links)
is_logseq_empty() {
    local logseq_file=$1

    if [ ! -f "$logseq_file" ]; then
        return 0  # File doesn't exist, consider empty
    fi

    # Read file and check for content other than PREV/NEXT links
    local has_content=0
    while IFS= read -r line; do
        # Skip empty lines
        if [ -z "$(echo "$line" | xargs)" ]; then
            continue
        fi

        # Skip PREV and NEXT links
        if echo "$line" | grep -qE '^\s*-\s*(PREV|NEXT):'; then
            continue
        fi

        # If we find any other content, mark as non-empty
        has_content=1
        break
    done < "$logseq_file"

    if [ "$has_content" -eq 0 ]; then
        return 0  # Empty
    else
        return 1  # Not empty
    fi
}

# Function to find previous non-empty Logseq entry
find_prev_entry() {
    local year=$1
    local month=$2
    local day=$3
    local max_iterations=365

    while [ $max_iterations -gt 0 ]; do
        # Decrement day
        day=$((10#$day - 1))

        # Handle month boundaries
        if [ $day -lt 1 ]; then
            month=$((10#$month - 1))
            if [ $month -eq 2 ]; then
                day=28
            elif [ $month -eq 4 ] || [ $month -eq 6 ] || [ $month -eq 9 ] || [ $month -eq 11 ]; then
                day=30
            else
                day=31
            fi
        fi

        # Handle year boundaries
        if [ $month -lt 1 ]; then
            month=12
            year=$((year - 1))
        fi

        # Format with leading zeros
        local year_str=$(printf "%04d" $year)
        local month_str=$(printf "%02d" $month)
        local day_str=$(printf "%02d" $day)

        local logseq_path="${LOGSEQ_DIR}/${year_str}_${month_str}_${day_str}.md"

        if [ -f "$logseq_path" ] && ! is_logseq_empty "$logseq_path"; then
            echo "${year_str},${month_str},${day_str}"
            return 0
        fi

        max_iterations=$((max_iterations - 1))
    done

    echo ""
    return 1
}

# Function to find next non-empty Logseq entry
find_next_entry() {
    local year=$1
    local month=$2
    local day=$3
    local max_iterations=365

    while [ $max_iterations -gt 0 ]; do
        # Increment day
        day=$((10#$day + 1))

        # Handle month boundaries
        if [ $day -gt 31 ] || ([ $month -eq 2 ] && [ $day -gt 29 ]) || \
           ([ $month -eq 4 ] && [ $day -gt 30 ]) || ([ $month -eq 6 ] && [ $day -gt 30 ]) || \
           ([ $month -eq 9 ] && [ $day -gt 30 ]) || ([ $month -eq 11 ] && [ $day -gt 30 ]); then
            day=1
            month=$((month + 1))
        fi

        # Handle year boundaries
        if [ $month -gt 12 ]; then
            month=1
            year=$((year + 1))
        fi

        # Format with leading zeros
        local year_str=$(printf "%04d" $year)
        local month_str=$(printf "%02d" $month)
        local day_str=$(printf "%02d" $day)

        local logseq_path="${LOGSEQ_DIR}/${year_str}_${month_str}_${day_str}.md"

        if [ -f "$logseq_path" ] && ! is_logseq_empty "$logseq_path"; then
            echo "${year_str},${month_str},${day_str}"
            return 0
        fi

        max_iterations=$((max_iterations - 1))
    done

    echo ""
    return 1
}

# Function to update PREV link in Logseq file
update_prev_link() {
    local logseq_file=$1
    local prev_year=$2
    local prev_month=$3
    local prev_day=$4

    if [ ! -f "$logseq_file" ]; then
        return
    fi

    local prev_display=$(format_display_date "$prev_year" "$prev_month" "$prev_day")
    local prev_link="- PREV: [[$prev_display]]"

    # Create temp file
    local temp_file=$(mktemp)

    # Check if PREV link exists
    if grep -q "^-\s*PREV:" "$logseq_file"; then
        # Replace existing PREV link
        sed "s|^-\s*PREV:.*|$prev_link|" "$logseq_file" > "$temp_file"
    else
        # Add PREV link at the beginning
        echo "$prev_link" > "$temp_file"
        cat "$logseq_file" >> "$temp_file"
    fi

    mv "$temp_file" "$logseq_file"
}

# Function to update NEXT link in Logseq file
update_next_link() {
    local logseq_file=$1
    local next_year=$2
    local next_month=$3
    local next_day=$4

    if [ ! -f "$logseq_file" ]; then
        return
    fi

    local next_display=$(format_display_date "$next_year" "$next_month" "$next_day")
    local next_link="- NEXT: [[$next_display]]"

    # Create temp file
    local temp_file=$(mktemp)

    # Check if NEXT link exists
    if grep -q "^-\s*NEXT:" "$logseq_file"; then
        # Replace existing NEXT link
        sed "s|^-\s*NEXT:.*|$next_link|" "$logseq_file" > "$temp_file"
        mv "$temp_file" "$logseq_file"
    else
        # Add NEXT link after PREV link if it exists, otherwise at the beginning
        if grep -q "^-\s*PREV:" "$logseq_file"; then
            awk -v next="$next_link" '/^-\s*PREV:/{print; print next; next}1' "$logseq_file" > "$temp_file"
            mv "$temp_file" "$logseq_file"
        else
            echo "$next_link" > "$temp_file"
            cat "$logseq_file" >> "$temp_file"
            mv "$temp_file" "$logseq_file"
        fi
    fi
}

# Function to add or update LaTeX link in Logseq file
update_latex_link() {
    local logseq_file=$1
    local pdf_path=$2

    if [ ! -f "$logseq_file" ]; then
        return
    fi

    local latex_link="- LaTeX: [[file://$pdf_path]]"

    # Check if LaTeX link already exists
    if grep -q "^-\s*LaTeX:" "$logseq_file"; then
        # Link already exists, don't update
        return
    fi

    # Add LaTeX link after NEXT link if it exists, otherwise after PREV
    local temp_file=$(mktemp)
    if grep -q "^-\s*NEXT:" "$logseq_file"; then
        awk -v latex="$latex_link" '/^-\s*NEXT:/{print; print latex; next}1' "$logseq_file" > "$temp_file"
        mv "$temp_file" "$logseq_file"
    elif grep -q "^-\s*PREV:" "$logseq_file"; then
        awk -v latex="$latex_link" '/^-\s*PREV:/{print; print latex; next}1' "$logseq_file" > "$temp_file"
        mv "$temp_file" "$logseq_file"
    else
        echo "$latex_link" > "$temp_file"
        cat "$logseq_file" >> "$temp_file"
        mv "$temp_file" "$logseq_file"
    fi
}

# Function to link handwritten notes
link_handwritten_notes() {
    local logseq_file=$1
    local year=$2
    local month=$3
    local day=$4

    local handwritten_dir="${ASSETS_DIR}/${year}/${month}/${day}"

    # Check if directory exists and has SVG files
    if [ ! -d "$handwritten_dir" ]; then
        return
    fi

    local svg_files=$(find "$handwritten_dir" -name "*.svg" | sort)
    if [ -z "$svg_files" ]; then
        return
    fi

    # Check if handwritten notes section already exists
    if grep -q "^## Handwritten Notes" "$logseq_file"; then
        return
    fi

    # Add handwritten notes section
    echo "" >> "$logseq_file"
    echo "## Handwritten Notes" >> "$logseq_file"

    for svg_file in $svg_files; do
        local filename=$(basename "$svg_file")
        local relative_path="../assets/svg/${year}/${month}/${day}/${filename}"
        echo "![]($relative_path)" >> "$logseq_file"
    done
}

# Main sync logic
sync_latex_to_logseq() {
    echo "Syncing LaTeX notes to Logseq..."

    # Find all LaTeX notes
    find "$NOTES_DIR" -type f -name "notes.tex" | sort | while read -r latex_file; do
        # Extract date from path (format: .../YYYY/MM/DD/notes.tex)
        local dir_path=$(dirname "$latex_file")
        local day=$(basename "$dir_path")
        local month=$(basename "$(dirname "$dir_path")")
        local year=$(basename "$(dirname "$(dirname "$dir_path")")")

        # Validate date format
        if ! [[ "$year" =~ ^[0-9]{4}$ ]] || ! [[ "$month" =~ ^[0-9]{2}$ ]] || ! [[ "$day" =~ ^[0-9]{2}$ ]]; then
            continue
        fi

        echo "Processing: $year-$month-$day"

        # Construct Logseq path
        local logseq_file="${LOGSEQ_DIR}/${year}_${month}_${day}.md"

        # Get PDF path
        local pdf_path="${dir_path}/notes.pdf"

        # Create or update Logseq file
        if [ ! -f "$logseq_file" ]; then
            # Create new file
            touch "$logseq_file"

            # Find previous entry
            local prev_entry=$(find_prev_entry "$year" "$month" "$day")
            if [ -n "$prev_entry" ]; then
                IFS=',' read -r prev_year prev_month prev_day <<< "$prev_entry"
                local prev_display=$(format_display_date "$prev_year" "$prev_month" "$prev_day")
                echo "- PREV: [[$prev_display]]" >> "$logseq_file"

                # Update previous entry's NEXT link
                local prev_logseq="${LOGSEQ_DIR}/${prev_year}_${prev_month}_${prev_day}.md"
                update_next_link "$prev_logseq" "$year" "$month" "$day"
            fi

            # Find next entry
            local next_entry=$(find_next_entry "$year" "$month" "$day")
            if [ -n "$next_entry" ]; then
                IFS=',' read -r next_year next_month next_day <<< "$next_entry"
                local next_display=$(format_display_date "$next_year" "$next_month" "$next_day")
                echo "- NEXT: [[$next_display]]" >> "$logseq_file"

                # Update next entry's PREV link
                local next_logseq="${LOGSEQ_DIR}/${next_year}_${next_month}_${next_day}.md"
                update_prev_link "$next_logseq" "$year" "$month" "$day"
            fi

            # Add LaTeX link
            echo "- LaTeX: [[file://$pdf_path]]" >> "$logseq_file"
        else
            # Update existing file
            update_latex_link "$logseq_file" "$pdf_path"
        fi

        # Link handwritten notes
        link_handwritten_notes "$logseq_file" "$year" "$month" "$day"
    done

    echo "Sync complete!"
}

# Run the sync
sync_latex_to_logseq
