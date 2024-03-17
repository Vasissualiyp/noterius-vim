combine_notes() {
    # Parameters: Year, Month, Notes Folder
    YEAR=$1
    MONTH=$2
    NOTES_FOLDER=$3

    # Convert month number to month name
    MONTH_NAME=$(date -d "$YEAR-$MONTH-1" +"%B")

    # Create the output file
	OUTPUT_DIR="$NOTES_FOLDER/$YEAR/$MONTH/combined"
	mkdir -p "$OUTPUT_DIR"
    OUTPUT_FILE="$OUTPUT_DIR/notes.tex"
    echo "\\documentclass{article}" > "$OUTPUT_FILE"
    echo "\\usepackage{catchfilebetweentags}" >> "$OUTPUT_FILE"
    echo "\\author{<author>}" >> "$OUTPUT_FILE"
    echo "\\title{Notes for $MONTH_NAME, $YEAR}" >> "$OUTPUT_FILE"
    echo "\\begin{document}" >> "$OUTPUT_FILE"
    echo "\\maketitle" >> "$OUTPUT_FILE"

    # Process each day's notes
    for DAY in $(seq -w 1 31); do
        DAY_FILE="$NOTES_FOLDER/$YEAR/$MONTH/$DAY/notes.tex"
        if [ -f "$DAY_FILE" ]; then
            echo "\\section{$MONTH_NAME, $DAY}" >> "$OUTPUT_FILE"
            echo "\\ExecuteMetaData[$DAY_FILE]{tagname}" >> "$OUTPUT_FILE"
        fi
    done

    echo "\\end{document}" >> "$OUTPUT_FILE"
    echo "Combined notes written to $OUTPUT_FILE"
}

notes_main_dir="$HOME/research/notes"
combine_notes 2024 02 $notes_main_dir
