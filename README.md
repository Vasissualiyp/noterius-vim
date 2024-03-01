# Noterius - Vim/Neovim Note-taking Utility

Noterius is a streamlined scientific cli-based note-taking utility designed for Vim/Neovim users who manage their notes in LaTeX format. It integrates seamlessly with your development environment, offering tools for note management, version control, and workspace cleanup. With Noterius, you can efficiently create, organize, and maintain your notes, all from within Vim/Neovim.

## Features

- **LaTeX Note Management**: Create and manage daily notes with a LaTeX template.
- **Version Control Integration**: Automatically commit and push your notes to a Git repository.
- **Workspace Cleanup**: Clean up your notes directory by removing unnecessary files and directories.

## Installation

1. Clone the Noterius repository to your local machine.
2. Navigate to the Noterius directory and make the scripts executable:
   ```
   chmod +x *.sh
   ```
3. Integrate Noterius into your Vim/Neovim workflow by adding custom commands or keybindings to call the scripts directly from your editor.

## Scripts Overview

### 1. `cleanup.sh`

Cleans up the notes directory by removing unnecessary files while preserving the primary `notes.tex` files.

#### Features:
- Removes all `notes.*` files except for `notes.tex`.
- Deletes directories containing `notes.tex` files with only comments or empty lines.

#### Usage:
```
./cleanup.sh
```

### 2. `git_commit_notes.sh`

Automates the process of committing your notes to a Git repository.

#### Features:
- Adds new or modified note files to the staging area.
- Commits the changes with a predefined message containing the commit date.
- Pushes the commit to the remote repository.

#### Usage:
```
./git_commit_notes.sh
```

### 3. `note.sh`

Manages LaTeX-based notes, supporting creation, deletion, and temporary file management.

#### Features:
- Creates a new note for the current day using a LaTeX template, filling in the current date.
- Allows for the removal of specific day's notes and temporary Vim/Neovim swap files.

#### Flags:
- `-r [date]`: Remove the note and its directory for the specified date.
- `-tempr [date]`: Remove temporary files for the specified date.

#### Usage:
Create/edit today's note:
```
./note.sh
```
Remove a specific day's note:
```
./note.sh -r YYYY-MM-DD
```
Remove temporary files for a specific day:
```
./note.sh -tempr YYYY-MM-DD
```

## Customization

Noterius is designed for flexibility. You can customize the LaTeX template (`notes_template.tex`) to suit your note-taking style. Furthermore, the scripts can be adjusted to fit your specific workflow or directory structure.

## Contribution

Contributions are welcome! Whether you're improving scripts, adding new features, or enhancing the LaTeX template, feel free to fork the project and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
