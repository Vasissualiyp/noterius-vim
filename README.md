# Noterius - Scientific Note-taking for Vim/NeoVim

Noterius is scientific note-taking utility tailored for Vim and NeoVim users, especially those who manage their notes in LaTeX. 
Noterius posesses seamless integration with NeoVim's Lua capabilities and optional Telescope support for advanced note searching and management. 
It aims to provide a comprehensive environment for creating, organizing, and maintaining scientific notes with ease.

## The Problem and The Solution

When you're jotting down your thoughts in a personal scientific journal, the freedom to tailor everything to your needs with handwriting is invaluable. Yet, the transition to formalizing these thoughts for publication—especially in LaTeX, a common format across many STEM fields—presents a notable challenge. The bulk of the early effort is spent transferring your handwritten notes into a digital LaTeX format.

Gilles Castel [introduced](https://castel.dev/post/lecture-notes-1/) a highly efficient workflow that combines Vim and the UltiSnips plugin for taking scientific lecture notes directly in LaTeX, achieving speeds comparable to handwriting. This solution effectively addresses the challenge of rapid LaTeX transcription. However, the creation of a comprehensive environment focused on the journaling aspect remained, in my view, an area for further enhancement.

Noterius is designed to fill this gap by addressing several key areas:
* **Organizing journal notes** in a straightforward manner.
* **Minimizing the memory impact** by managing LaTeX compilation byproducts efficiently.
* **Facilitating easy and frictionless navigation** through journal entries.
* **Integrating version control** to ensure notes are backed up to online git repositories, making them accessible from anywhere.
* **Simplifying citation management** (with Citerius, an extension aimed at streamlining this process)
* **Enhancing search capabilities** over years' worth of journal entries through grep and fuzzy finder functionalities, exclusive to the (NeoVim version only)

By focusing on these improvements, Noterius aims to provide a robust environment that mirrors the ease of handwritten note-taking while leveraging the power of LaTeX for scientific documentation. This approach is intended for those who appreciate the nuances of academic work and seek to optimize their workflow in capturing and organizing their research insights.

## Features

- **LaTeX Note Management**: Effortlessly create and manage your daily notes using a customizable LaTeX template.
- **Version Control Integration**: Automatically track changes to your notes with integrated Git support, ensuring your work is always saved and synchronized.
- **Workspace Cleanup**: Maintain a tidy workspace by removing unnecessary files and directories, keeping only what's essential.
- **Telescope Integration** (NeoVim only): Utilize the power of Telescope for searching and managing notes with features like live grep and file finding, enhancing your note-taking workflow.

## Installation Guide for Noterius

Noterius enhances your note-taking process in Vim/Neovim, especially for LaTeX users. It organizes notes, integrates version control, and, for Neovim users, offers powerful search functionalities through Telescope.

### Prerequisites

- Vim or Neovim installed on your system.
- Neovim users looking to utilize the Telescope integration will need [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and [Ripgrep](https://github.com/BurntSushi/ripgrep).

### Installation

#### For Vim Users

1. **Vim-Plug**
   ```vim
   Plug 'Vasissualiyp/noterius-vim'
   ```
2. **Vundle**
   ```vim
   Plugin 'Vasissualiyp/noterius-vim'
   ```
3. **Pathogen**
   ```shell
   cd ~/.vim/bundle
   git clone https://github.com/Vasissualiyp/noterius-vim.git
   ```

#### For Neovim Users

1. **Vim-Plug**
   ```vim
   Plug 'Vasissualiyp/noterius-vim'
   ```
2. **Packer**
   ```lua
   use {'Vasissualiyp/noterius-vim'}
   ```
3. **Lazy**
   ```vim
   'Vasissualiyp/noterius-vim'
   ```

After installing, remember to run `:PlugInstall` or the equivalent command for your plugin manager to activate Noterius.

#### ⚠️ Incompatability ⚠️
The telescope grep currently breaks if you also have vimspector installed.

#### Setup of Noterius environment

After you have downloaded the plugin, please see below for suggested configuration. Include the configuration in the editor of your choice.
Make sure that you define the global variables as you would like (i.e. your name, remote git url if you will be using it...)
If you are going to use any remote git repo (i.e. GitHub), create it before you add the url. Make sure to do all that before you setup Noterius below,
and do not commit anything in that repo yet!

After you restarted the editor, run `:SetupNoteriusNotes`. This will create the directory for the notes, that you have specified in your configuration file,
copy template files for latex header, overall notes template and quickhelp menu. All those files will be referenced in your future configurations,
so if you want to change them, change them in your notes repo.

Once the script was ran, you now can use `:NoteriusToday` (or your pre-defined keybind) to create a note for the current day.

### Configuration

Here are suggested configurations for vim (`.vimrc`) and neovim (`init.lua`)

#### Vim 
Add the following to your .vimrc:
```
Copy code
" Global variables
let g:noterius_notes_dir = '~/research/notes'
let g:noterius_git_url = 'git@github.com:your_git_username/your_git_dir.git'

" Folding keymaps
nnoremap <leader>zo :execute "normal! ggVGzo"<CR>
nnoremap <leader>zm :execute "normal! ggVGzc"<CR>

" Note management keybindings
nnoremap <leader>N :NoteriusToday<CR>
nnoremap <leader>nc :NoteriusCleanup<CR>
nnoremap <leader>nn :FindNextNote<CR>
nnoremap <leader>np :FindPreviousNote<CR>
nnoremap <leader>no :OpenNoteByDate<CR>
nnoremap <leader>n? :DisplayNoteriusQuickhelp<CR>
nnoremap <leader>np :NoteriusGitPush<CR>
nnoremap <leader>ns :NoteriusSyncWithRemoteRepo<CR>

" Initialize Noterius paths on Vim start - AFTER definition of global variables
autocmd VimEnter * call noterius#InitPaths()
```

This setup for Vim includes the necessary global variable definitions, a command to initialize Noterius paths when Vim starts, and keybindings for both note management and folding.

#### Neovim Configuration
For your init.lua in Neovim:

```
Copy code
-- Global variables
vim.g.noterius_notes_dir = '~/research/notes'
vim.g.noterius_git_url = 'git@github.com:your_git_username/your_git_dir.git'

-- Folding keymaps
vim.keymap.set('n', '<leader>zo', 'ggVGzO<Esc>', { silent = true })
vim.keymap.set('n', '<leader>zm', 'ggVGzM<Esc>', { silent = true })

-- Note management keybindings
vim.keymap.set('n', '<leader>N' , ':NoteriusToday<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nc', ':NoteriusCleanup<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nn', ':FindNextNote<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>np', ':FindPreviousNote<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>no', ':OpenNoteByDate<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>n?', ':DisplayNoteriusQuickhelp<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>np', ':NoteriusGitPush<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ns', ':NoteriusSyncWithRemoteRepo<CR>', { noremap = true, silent = true })

-- Additional Neovim-specific keybindings for enhanced functionality
-- Include any Neovim-specific keybindings here, like those for Telescope

-- Initialize Noterius. This MUST be included after the definitions of global variables!
require('noterius-vim.init').setup({
  notes_dir = '~/research/notes',
  author = 'Your Name',
  citerius_integration = 1,
  citerius_src_dir = '~/research/references',
})
```
This Neovim setup mirrors the Vim configuration while providing the flexibility to include Neovim-specific keybindings or features, such as those provided by Telescope.

Notes:
Both configurations define the same global variables and include keybindings for folding and note management.
The Neovim setup uses Lua for defining keybindings and setting up Noterius, including extra functions that might be specific to Neovim.
The autocmd VimEnter * call noterius#InitPaths() in the Vim setup and the corresponding Lua setup in Neovim ensure that Noterius is correctly initialized after all configurations are loaded.
Adjust the paths and URLs as necessary to fit your setup.

## Usage

Noterius sources template files in the notes directory. Whenever you create a new journal entry for today (a single entry is supported per day),
the `notes_template.tex` file gets copied, and all variables in angled brackets get altered (i.e. <today> becomes the current date).
The `header.tex` file gets included in that file. In this header file, you can define all custom functions (like note is defined as an example), and
since the header is sourced in every single journal entry, the same header would automatically apply to all notes.
This was done to improve customizability and decrease the disk space bloat that would happen if your headers tend to be large.

You can obtain notes for a specific date by using `:OpenNoteByDate` and following with the note in YYYY-MM-DD format.
The same function also would open the last weekday note, if you provide a weekday 3-letter anagram 
(So if today is Tuesday, and you ask for Wed note, it would open a note from 6 days ago if it exists)

You can jump to next/previous note using `:FindNextNote/:FindPreviousNote`.

`:DisplayNoteriusQuickhelp` would display a quickhelp menu for your personal use that you can modify.
For instance, I use it to associate the colors of the notes with a type of a note.

`:NoteriusCleanup` would cleanup all the build files. This is useful to do periodically to prevent the notes taking a lot of space with all the buildfiles and pdfs,
unless you are using `:NoteriusGitPush`.

`:NoteriusSyncWithRemoteRepo` git pulls from the remote git repo that you have defined.

`:NoteriusGitPush` performs cleanup and commits the notes to git repo. No build files or pdfs get committed, since the cleanup gets rid of them.
Any extra files that you leave in the directory (i.e. other directories with your figures) will be committed.

## Upcoming Features 

Seamless integration with my Citerius utility would simplify reference management.

## Customization

Customize your LaTeX templates in the `templates` folder to match your note-taking preferences. Further customization options and additional functionalities will be progressively documented and made available, ensuring Noterius adapts to your workflow.

My personal suggestion is to read up on aforementioned [workflow](https://castel.dev/post/lecture-notes-1/) by Giles Castelle, which was a major inspiration for this project.
It also tells you about the use of `UltiSnips` vim plugin, which enchances notetaking dramatically.

## Contribution

Contributions to Noterius are highly encouraged. Whether it's by refining the code, adding new features, or improving documentation, your input is welcome. Please fork the repository and submit a pull request with your changes.

## License

Noterius is open-sourced under the MIT License. For more details, see the LICENSE file in the project repository.
