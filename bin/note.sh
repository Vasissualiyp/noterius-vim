#!/usr/bin/env bash

author="Vasilii Pustovoit"
citerius_integration=1 # 1 to enable citerius integration

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
NOTERIUS_SRC_DIR="$SCRIPT_DIR/.."
CITERIUS_SRC_DIR="$HOME/research/references"
TEMPLATES_SRC_DIR="$NOTERIUS_SRC_DIR/templates"

notes_main_dir="$HOME/research/notes"
template_path="${TEMPLATES_SRC_DIR}/notes_template.tex"

# Get the current time in hours and minutes
current_time=$(date +%H:%M)

# Get the current date in YYYY-MM-DD format
current_date=$(date +%Y-%m-%d)

cd $HOME

# Setting up the environment  {{{
source ~/env/venv/bin/activate
inkscape-figures watch
# Run the tablet regulator script for inkscape
if pgrep -f "tablet_regulator" > /dev/null; then
  echo "inkscape_tablet_regulator is already running"
else
  echo "The script is not running. Starting the script."
  nohup ./scripts/inkscape_tablet_regulator.sh > /dev/null &
fi
#}}}

# Set the date of the file as needed {{{
# Check if an argument is provided for the date
if [ $# -eq 1 ]; then
  case "$1" in
    "yesterday")
      current_date=$(date --date='yesterday' +%Y-%m-%d)
      ;;
    "last")
      current_date=$(cat ~/research/notes/.last_note_date)
      ;;
    *)
      # If the argument has only two fields (MM-DD), add the current year
      if [ $(echo $1 | grep -c '^[0-9][0-9]-[0-9][0-9]$') -eq 1 ]; then
        current_date=$(date +%Y)-$1
      else
        current_date=$1
      fi
      ;;
  esac
fi

# Check if it's before 3am and open the notes for yesterday
if [ "$current_time" \< "03:00" ]; then
  current_date=$(date --date='yesterday' +%Y-%m-%d)
fi
#}}}

# Set the path to the directory and the current date {{{
year=$(echo $current_date | cut -d '-' -f1)
month=$(echo $current_date | cut -d '-' -f2)
day=$(echo $current_date | cut -d '-' -f3)
dir_path="$notes_main_dir/$year/$month/$day"
file_path="$dir_path/notes.tex"
tempfile_path1="$dir_path/.notes.tex.swp"
tempfile_path2="$dir_path/.notes.tex.swo"
#}}}

#Check existence of file and directory {{{
# Check if the directory exists
if [ ! -d "$dir_path" ]; then
  # Create the directory if it does not exist
  mkdir -p "$dir_path"
fi

# Check if the file exists
if [ ! -f "$file_path" ]; then
  # Copy the template file to the new file if it does not exist
  cp "$template_path" "$file_path"

  # Replace <today> with the current date in the file
  sed -i "s/<today>/$current_date/g" "$file_path"
  sed -i "s|<noterius_src>|${NOTERIUS_SRC_DIR}|g" "$file_path"
  sed -i "s/<author>/$author/g" "$file_path"
  if [ "$citerius_integration" -eq 1 ]; then
      sed -i "s|<citations_src>|${CITERIUS_SRC_DIR}|g" "$file_path"
  else
      # Remove the whole line that contains anything bibliography-related
      sed -i '/citations_src/d' "$file_path"
      sed -i '/printbibliography/d' "$file_path"
  fi
fi
#}}}

# Check if remove flag is set {{{
if [[ "$1" == "-r" ]]; then
  # Check if file exists and delete it
  if [ -f "$file_path" ]; then
    rm -r  "$dir_path"
    echo "Note for $2 has been removed."
  else
    echo "Note for $2 not found."
  fi
  exit 0
fi
#}}}

# Check if temp remove flag is set {{{
if [[ "$1" == "-tempr" ]]; then
  # Check if file exists and delete it
  if [ -f "$tempfile_path1" ]; then
    rm  "$tempfile_path1"
    echo "Temporary swp note file for $2 has been removed."
  else
    echo "Temporary swp note file for $2 not found."
  fi
  if [ -f "$tempfile_path2" ]; then
    rm  "$tempfile_path2"
    echo "Temporary swo note file for $2 has been removed."
  else
    echo "Temporary swo note file for $2 not found."
  fi
  exit 0
fi
#}}}

# Save the current date as the last opened note date
echo "$current_date" > ~/research/notes/.last_note_date

# Open the file in vim and place the cursor on line n
#vim -c "1,/begin{document}/-1 fold" + "$file_path"
cd "$dir_path"
nvim -c "set foldmethod=marker" "$file_path"
#vim -c "set foldmethod=marker" "$file_path"
