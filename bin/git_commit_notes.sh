#!/usr/bin/env bash

# Location of the notes
notes_dir="$1"

github_integration="$2" #1 for true

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
if [[ $github_integration -eq 1 ]]; then
    git push origin main
fi
