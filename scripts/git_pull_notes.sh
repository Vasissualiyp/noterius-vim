#!/usr/bin/env bash

# Location of the notes
notes_main_dir="$HOME/research/notes"

# Cleanup the notes
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Loop through all directories in the notes directory
cd "$notes_main_dir" || { echo "Notes directory doesn't exist"; exit; }

git pull
echo ""
echo "Pulled all the notes now"
