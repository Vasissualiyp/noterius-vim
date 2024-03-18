# Noterius-Vim - Enhanced Scientific Note-taking for Vim/Neovim

Noterius-Vim is an enhanced scientific note-taking utility tailored for Vim and Neovim users, especially those who manage their notes in LaTeX. Building upon the foundation of the original Noterius utility, Noterius-Vim introduces seamless integration with Neovim's Lua capabilities and optional Telescope support for advanced note searching and management. It aims to provide a comprehensive environment for creating, organizing, and maintaining scientific notes with ease.

## Features

- **LaTeX Note Management**: Effortlessly create and manage your daily notes using a customizable LaTeX template.
- **Version Control Integration**: Automatically track changes to your notes with integrated Git support, ensuring your work is always saved and synchronized.
- **Workspace Cleanup**: Maintain a tidy workspace by removing unnecessary files and directories, keeping only what's essential.
- **Telescope Integration** (Neovim only): Utilize the power of Telescope for searching and managing notes with features like live grep and file finding, enhancing your note-taking workflow.

## Installation

### Prerequisites

- Vim or Neovim installed on your machine.
- For Neovim users wanting to use Telescope features, [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) must be installed along with [Ripgrep](https://github.com/BurntSushi/ripgrep) for file searching capabilities.

### Steps

1. Use your preferred Vim/Neovim package manager to install `noterius-vim`. For example, with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'username/noterius-vim'
```

2. For Neovim users, ensure your `init.lua` or equivalent configuration file is set up to utilize Noterius-Vim's Lua-based features and Telescope integration as shown in the Keymaps section below.

## Keymaps

Configure keymaps for note management and optional Telescope integration in your `init.lua`:

```lua
local notes_dir = vim.fn.expand('~/research/notes')

require('noterius-vim.noterius_telescope').setup({
  notes_dir = notes_dir,
})

-- Folding keymaps
vim.keymap.set('n', '<leader>zo', 'ggjVGkkzo<Esc><Esc>gg', { silent = true })
vim.keymap.set('n', '<leader>zm', 'ggjVGkkzm<Esc><Esc>gg', { silent = true })

-- Note management keymaps
vim.keymap.set('n', '<leader>nn', ':FindNextNote<CR>', { silent = true })
vim.keymap.set('n', '<leader>np', ':FindPreviousNote<CR>', { silent = true })
vim.keymap.set('n', '<leader>no', ':OpenNoteByDate<CR>', { silent = true })
vim.keymap.set('n', '<leader>n?', ':DisplayNoteriusQuickhelp<CR>', { silent = true })

-- Optional Telescope integration for Neovim
local noterius_telescope = require('noterius-vim.noterius_telescope')
vim.keymap.set('n', '<leader>ng', noterius_telescope.grep_notes, { silent = true })
vim.keymap.set('n', '<leader>nf', noterius_telescope.find_notes, { silent = true })
```

## Upcoming Features and Integration

Future releases aim to fully integrate the original Noterius's bash script functionalities directly into Vimscript and Lua, offering a unified and streamlined experience across both Vim and Neovim. These will include enhanced version control automation, sophisticated workspace cleanup, and dynamic LaTeX note generation and management.

## Customization

Customize your LaTeX template (`notes_template.tex`) to match your note-taking preferences. Further customization options and additional functionalities will be progressively documented and made available, ensuring Noterius-Vim adapts to your workflow.

## Contribution

Contributions to Noterius-Vim are highly encouraged. Whether it's by refining the code, adding new features, or improving documentation, your input is welcome. Please fork the repository and submit a pull request with your changes.

## License

Noterius-Vim is open-sourced under the MIT License. For more details, see the LICENSE file in the project repository.
