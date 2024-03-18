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

### Configuration

#### Vim

In your `.vimrc`, you can set keybindings directly. While Noterius's advanced search features with Telescope are exclusive to Neovim, basic note management is fully available in Vim.

```vim
" Keybindings for managing notes
nnoremap <leader>nn :FindNextNote<CR>
nnoremap <leader>np :FindPreviousNote<CR>
nnoremap <leader>no :OpenNoteByDate<CR>
nnoremap <leader>n? :DisplayNoteriusQuickhelp<CR>
```

#### Neovim

For Neovim users, `init.lua` allows you to set up Noterius and integrate with Telescope if installed. Below is how you configure it, including what each line does:

```lua
-- Define the directory where your notes are stored
local notes_dir = vim.fn.expand('~/research/notes')

-- Set up Noterius with the path to your notes
require('noterius-vim.noterius_telescope').setup({
  notes_dir = notes_dir,
})

-- Keybindings for note folding
vim.keymap.set('n', '<leader>zo', 'ggjVGkkzo<Esc><Esc>gg', { silent = true }) -- Fold opened notes
vim.keymap.set('n', '<leader>zm', 'ggjVGkkzm<Esc><Esc>gg', { silent = true }) -- Fold closed notes

-- Basic note management keybindings
vim.keymap.set('n', '<leader>nn', ':FindNextNote<CR>', { silent = true }) -- Find the next note
vim.keymap.set('n', '<leader>np', ':FindPreviousNote<CR>', { silent = true }) -- Find the previous note
vim.keymap.set('n', '<leader>no', ':OpenNoteByDate<CR>', { silent = true }) -- Open a note by date
vim.keymap.set('n', '<leader>n?', ':DisplayNoteriusQuickhelp<CR>', { silent = true }) -- Display quick help

-- Telescope integration for enhanced search in Neovim
local noterius_telescope = require('noterius-vim.noterius_telescope')
vim.keymap.set('n', '<leader>ng', noterius_telescope.grep_notes, { silent = true }) -- Grep through notes
vim.keymap.set('n', '<leader>nf', noterius_telescope.find_notes, { silent = true }) -- Find notes by name
```

This setup enables:
- Folding and unfolding of your notes for better readability.
- Navigation between notes based on a chronological sequence or specific dates.
- Quick access to a help overview.
- **For Neovim users**: Utilizing Telescope to search within your notes by content or filename, significantly enhancing your ability to find specific entries.

Remember, the Telescope-based features are specific to Neovim due to its Lua integration capabilities, offering a richer, more interactive experience when dealing with extensive notes.

## Upcoming Features and Integration

Future releases aim to fully integrate the original Noterius's bash script functionalities directly into Vimscript and Lua, offering a unified and streamlined experience across both Vim and NeoVim. These will include enhanced version control automation, sophisticated workspace cleanup, and dynamic LaTeX note generation and management.

## Customization

Customize your LaTeX template (`notes_template.tex`) to match your note-taking preferences. Further customization options and additional functionalities will be progressively documented and made available, ensuring Noterius adapts to your workflow.

## Contribution

Contributions to Noterius are highly encouraged. Whether it's by refining the code, adding new features, or improving documentation, your input is welcome. Please fork the repository and submit a pull request with your changes.

## License

Noterius is open-sourced under the MIT License. For more details, see the LICENSE file in the project repository.
