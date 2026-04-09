#!/usr/bin/env bash

# Location of the notes
notes_dir="$1"

github_integration="$2" #1 for true

# Logseq integration parameters
logseq_enabled="${3:-0}"
logseq_dir="${4:-}"

# Define the minimum acceptable year (first note)
min_year=2023

# Cleanup the notes - FOR NOW THIS IS ASSUMED AS TRUE
#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#cd "$SCRIPT_DIR"
#./cleanup.sh

# Get the current year
current_year=$(date +%Y)

# Loop through all directories in the notes directory
cd "$notes_dir" || { echo "Notes directory doesn't exist"; exit; }
for dir in */ ; do
    # Remove the trailing slash to just get the directory name
    dir_name=${dir%/}
    
    # Check if the directory name is a number
    if [[ $dir_name =~ ^[0-9]+$ ]]; then
        # If the directory name is a year within the acceptable range, add it to git
        if [ $dir_name -ge $min_year ] && [ $dir_name -le $current_year ]; then
            echo "Adding $dir_name to git..."
            git add "$dir_name"
        fi
    fi
done

# Commit with a message including the current date and time
commit_message="notes update from $(date)"
git commit -m "$commit_message"
echo "Committed with message: '$commit_message'"

# Handle Logseq commits if enabled
if [[ $logseq_enabled -eq 1 ]] && [[ -n "$logseq_dir" ]]; then
    echo "Processing Logseq commits..."

    # Expand the logseq directory path
    logseq_dir_expanded=$(eval echo "$logseq_dir")

    # Check if Logseq directory exists
    if [ -d "$logseq_dir_expanded" ]; then
        # Change to Logseq directory
        cd "$logseq_dir_expanded" || { echo "Failed to change to Logseq directory"; exit; }

        # Check if it's a git repository
        if [ -d ".git" ]; then
            # Add all markdown files
            git add *.md 2>/dev/null || true

            # Check if there are changes to commit
            if git diff --staged --quiet; then
                echo "No changes to commit in Logseq directory"
            else
                # Commit Logseq changes
                logseq_commit_message="logseq notes update from $(date)"
                git commit -m "$logseq_commit_message"
                echo "Committed Logseq with message: '$logseq_commit_message'"

                # Push if github integration is enabled
                if [[ $github_integration -eq 1 ]]; then
                    git push origin main
                    echo "Pushed Logseq changes to remote"
                fi
            fi
        else
            echo "Warning: Logseq directory is not a git repository"
        fi

        # Return to notes directory
        cd "$notes_dir" || { echo "Failed to return to notes directory"; exit; }
    else
        echo "Warning: Logseq directory does not exist: $logseq_dir_expanded"
    fi
fi

# Push LaTeX notes if github integration is enabled
if [[ $github_integration -eq 1 ]]; then
    git push origin main
    echo "Pushed LaTeX notes to remote"
fi
