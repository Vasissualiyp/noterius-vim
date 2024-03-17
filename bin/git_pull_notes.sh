#!/usr/bin/env bash

# Location of the notes
notes_main_dir="$HOME/research/notes"
git_notes="git@github.com:Vasissualiyp/Research_notes.git"

create_notes_dir() {	
        echo "Notes directory doesn't exist. Creating...";
		mkdir -p "$notes_main_dir"
		cd "$notes_main_dir"
		git init
		git remote add origin "$git_notes"
		git pull origin main
}

# Cleanup the notes
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Loop through all directories in the notes directory
{ cd "$notes_main_dir"; git pull; } || create_notes_dir

echo ""
echo "Pulled all the notes now"
