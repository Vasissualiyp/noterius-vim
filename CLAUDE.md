CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Noterius is a Vim/NeoVim plugin for scientific note-taking in LaTeX. It creates daily journal entries organized in a YYYY/MM/DD directory structure, integrates with git for version control, and provides enhanced search capabilities through Telescope.nvim (NeoVim only).

## Architecture

### Dual Implementation Strategy

Noterius maintains Vim compatibility while enhancing NeoVim:

- **VimScript Layer** (`autoload/noterius.vim`): Contains all core functionality, works in both Vim and NeoVim
- **Lua Layer** (`lua/noterius-vim/`): NeoVim-specific enhancements, wraps VimScript functions and adds Telescope integration
- **Bridge Pattern**: Lua setup() → sets global variables → calls VimScript InitPaths() → VimScript handles logic

### Directory Structure

```
plugin/             # Command registration (entry point)
autoload/           # Core VimScript functions (lazy-loaded)
lua/                # NeoVim-specific Lua code
  └── noterius-vim/
      ├── init.lua              # Setup and configuration
      └── noterius_telescope.lua # Telescope search integration
bin/                # Shell scripts for note management
  ├── note.sh                   # Standalone note creation
  ├── cleanup.sh                # Remove build files and empty notes
  ├── git_commit_notes.sh       # Git commit and push
  ├── git_pull_notes.sh         # Git pull/initial setup
  └── combine_notes.sh          # Monthly note compilation
templates/          # LaTeX template files
  ├── header.tex                # Shared LaTeX configuration (included by all notes)
  ├── notes_template.tex        # Daily note template
  └── quickhelp.tex             # User-customizable reference
```

### Notes Directory Structure

User notes follow this hierarchy:

```
notes_dir/
├── YYYY/MM/DD/notes.tex    # Daily notes
├── YYYY/MM/DD/figures/     # Optional inkscape figures
├── YYYY/MM/combined/       # Optional monthly compilations
├── templates/              # Copied during SetupNoteriusNotes
└── .git/                   # Version control
```

## Key Components

### autoload/noterius.vim (Core Logic)

**noterius#InitPaths()**: Initializes all global variables and calculates paths. Called on VimEnter. Sets defaults for:
- `g:noterius_notes_dir` (~/research/test)
- `g:noterius_author` (User)
- `g:citerius_integration` (0)
- `g:noterius_github_integration` (0)

**noterius#NoteriusToday()**: Creates/opens today's note. If new, copies template from `notes_template.tex`, replaces placeholders (`<today>`, `<author>`, `<citations_src>`, `<noterius_src>`), and opens file.

**Navigation Functions**:
- `noterius#FindNextNote()` / `noterius#FindPreviousNote()`: Search up to 365 days forward/backward
- `noterius#OpenNoteByDate()`: Opens by YYYY-MM-DD or weekday abbreviation (Mon, Tue, etc.)

**noterius#ReplacePlaceholders()**: Substitutes template variables. Conditionally includes bibliography based on `g:citerius_integration`.

### lua/noterius-vim/noterius_telescope.lua

**M.grep_notes()**: Live grep search using `telescope.builtin.live_grep()`, filters only `.tex` files, custom path display shows `DD/MM/YYYY/filename`.

**M.search_notes()**: Find files using `telescope.builtin.find_files()` with ripgrep backend, same filtering and formatting.

**Path Display Logic**: Extracts YYYY/MM/DD from path, reformats to DD/MM/YYYY for readability.

### bin/cleanup.sh

**check_file()**: Determines if note has content by extracting text between `\begin{document}` and `\end{document}`, filtering structural LaTeX.

**cleanup_notes_files()**: Removes build artifacts (`notes.aux`, `notes.pdf`, etc.) while preserving `notes.tex`.

**Main Loop**: Recursively processes all day directories, removes build files from notes with content, deletes entire directories for empty notes.

### bin/git_commit_notes.sh

Stages year directories (2023+), creates timestamped commit message, optionally pushes to GitHub if `github_integration` enabled.

### bin/git_pull_notes.sh

Handles two scenarios:
1. First setup: Creates directory, initializes git repo, adds remote, pulls
2. Existing setup: Simple `git pull origin main`

## Configuration Variables

Set in `.vimrc` or `init.lua` before calling `noterius#InitPaths()`:

```vim
g:noterius_notes_dir          " Root directory for notes
g:noterius_author             " Author name for LaTeX
g:citerius_integration        " 0/1 to enable bibliography
g:noterius_github_integration " 0/1 to enable GitHub push
g:citerius_src_dir            " Bibliography directory
g:noterius_git_url            " Remote git URL (optional)
```

Auto-calculated globals (don't set manually):
- `g:noterius_source_dir`, `g:noterius_templates_dir`
- `g:current_date`, `g:current_date_dirfmt`
- `g:noterius_todays_dir`, `g:noterius_todays_file`

## Commands

| Command | Implementation | Purpose |
|---------|----------------|---------|
| `:NoteriusToday` | `noterius#NoteriusToday()` | Open/create today's note |
| `:SetupNoteriusNotes` | `noterius#SetupNoteriusNotes()` | Initial setup, copies templates |
| `:NoteriusCleanup` | `noterius#NoteriusCleanup()` | Remove LaTeX build files |
| `:NoteriusGitPush` | `noterius#NoteriusGitPush()` | Cleanup + commit + push |
| `:NoteriusGitPull` | `noterius#NoteriusSyncWithRemoteRepo()` | Pull from remote |
| `:FindNextNote` | `noterius#FindNextNote()` | Navigate to next note (365 day search) |
| `:FindPreviousNote` | `noterius#FindPreviousNote()` | Navigate to previous note |
| `:OpenNoteByDate` | `noterius#OpenNoteByDate()` | Open by YYYY-MM-DD or weekday |
| `:DisplayNoteriusQuickhelp` | `noterius#DisplayNoteriusQuickhelp()` | Show quickhelp |

## Development Workflow

### Testing Changes

No automated tests exist. Manual testing workflow:

1. Create test notes directory: `mkdir -p ~/test_notes`
2. Configure test instance:
   ```vim
   let g:noterius_notes_dir = '~/test_notes'
   let g:noterius_author = 'Test User'
   ```
3. Run `:SetupNoteriusNotes` to initialize
4. Test commands manually with various scenarios
5. Verify file operations in `~/test_notes/YYYY/MM/DD/`

### Common Development Tasks

**Modifying VimScript Functions**:
- Edit `autoload/noterius.vim`
- Restart Vim/NeoVim or `:source autoload/noterius.vim`
- Test affected commands

**Modifying Lua Functions**:
- Edit files in `lua/noterius-vim/`
- Restart NeoVim or `:lua package.loaded['noterius-vim.init'] = nil` then reload
- Test with Telescope commands

**Modifying Shell Scripts**:
- Edit files in `bin/`
- Make executable: `chmod +x bin/script.sh`
- Test directly: `bash bin/script.sh args` or via Vim commands

**Modifying Templates**:
- Edit files in `templates/`
- Delete test notes and recreate to see changes
- User templates (in notes_dir/templates/) override plugin templates

### Debugging

**VimScript Debugging**:
- Add `echom "Debug: " . variable` statements
- View with `:messages`
- Check variables: `:echo g:noterius_todays_file`

**Lua Debugging**:
- Use `vim.notify()` or `print()`
- View with `:messages`
- Inspect: `:lua print(vim.inspect(variable))`

**Shell Script Debugging**:
- Add `set -x` at top for verbose output
- Run scripts with `bash -x bin/script.sh`

## Important Implementation Details

### Placeholder Replacement System

Template files use angle bracket placeholders replaced during note creation:
- `<today>` → Current date in YYYY-MM-DD format
- `<author>` → Value of `g:noterius_author`
- `<citations_src>` → Value of `g:citerius_src_dir`
- `<noterius_src>` → Value of `g:noterius_source_dir`

Replacement happens in `noterius#ReplacePlaceholders()` using Vim's `substitute()`.

### Date Calculation Logic

Navigation functions (`FindNextNote`, `FindPreviousNote`) manually handle date arithmetic:
- Increment/decrement day
- Handle month boundaries (28/29/30/31 days)
- Handle year boundaries
- Search up to 365 days in each direction
- Stop at first found note

### Content Detection in cleanup.sh

The `check_file()` function determines if a note has content:
1. Extracts lines between `\begin{document}` and `\end{document}`
2. Removes lines containing: `\newpage`, `\bibliography`, `\maketitle`
3. Removes LaTeX comments (lines starting with %)
4. If remaining lines exist → note has content
5. Empty notes get deleted entirely (directory removed)

### Telescope Path Display

Custom `path_display` function in `noterius_telescope.lua`:
1. Splits path by separator
2. Finds notes_dir index in path components
3. Extracts YYYY/MM/DD/filename
4. Reformats to DD/MM/YYYY/filename for readability
5. Returns formatted string for display

### Git Integration Workflow

`:NoteriusGitPush` sequence:
1. Call `bin/cleanup.sh` to remove build files and empty notes
2. Call `bin/git_commit_notes.sh` to stage, commit, and push
3. Only year directories (2023+) get staged
4. Commit message: `"notes update from $(date)"`
5. Push to origin/main if `github_integration` enabled

### Template Sourcing Priority

1. Plugin templates in `<plugin_dir>/templates/` (read-only)
2. User templates in `<notes_dir>/templates/` (customizable)
3. `:SetupNoteriusNotes` copies plugin templates to notes_dir
4. Users modify templates in notes_dir (not tracked by plugin git)
5. `header.tex` included by all notes via `\input{<noterius_src>/templates/header.tex}`

## Known Issues

**Telescope Grep Incompatibility**: Telescope grep breaks when vimspector plugin is installed. No known workaround.

**Before 3 AM Logic**: `bin/note.sh` has logic to open yesterday's note before 3 AM. This is not implemented in VimScript functions.

**Inkscape Integration**: Templates reference inkscape-figures workflow but plugin doesn't manage inkscape. Users must set up separately.

## Version Control

This repository tracks the plugin code itself. User notes are versioned in separate repositories specified by `g:noterius_git_url`.
