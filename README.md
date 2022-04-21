# My personal dot file repository

This is the 2022 reboot of my dotfiles. Let's see where we end up.

The core principle behind this is to make it as platform independent as possible, with minimal configuration of the terminal application, to provide similar experience disregarding driving os.

I'm trying out using GNU Stow to manage my dotfiles, rather than using my hackety hacks bootstrapping scripts. This will probably be a bumpy ride, but isn't that part of what makes this fun?

macOS terminal client of choice is [iTerm 2](https://iterm2.com).
Ubuntu on Windows 10 runs through [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), with [Microsoft Terminal](https://github.com/Microsoft/Terminal).
On iOS I use [Blink Shell](https://blink.sh).

At the moment, I'm evaluating [Gruvbox](https://github.com/morhetz/gruvbox) as my color scheme. I used to use [Nord](https://www.nordtheme.com/), but my eyes are not what they used to, and I needed something new and contrasty.

## Install Scripts
Use the install scripts to install dependencies, to prepare a new system before using dotfiles. _Prompt will break if Oh My Posh is not present_. Config of fallback prompt is in the backlog. 🤓

## Scripts

The scripts folder is where I keep my small utility scripts, for day to day tasks.

_./_
- fports - Opens ssh connetion to remote system, and forwards port from remote to localhost.
- dailyNote - Looks for daily note in vault. If it exists, it opens in $EDITOR(AKA Neovim). If it's not present, a new note for today is created from template, before opening it in $EDITOR.
- quickReadNote -Use `fzf` to select daily note, and display it using `bat`.
- newTmuxSession - Creates a new tmux session from current directory, with provided name, or attach/switch to existing session if present.

_./lib_:
- slugify - Takes in a string, and transforms it into a slug. [DJ Adams](https://github.com/qmacro/dotfiles/blob/main/scripts/lib/slugify)
- yyyymmdd - Returns correctly formated date. [DJ Adams](https://github.com/qmacro/dotfiles/blob/main/scripts/lib/yyyymmdd)

## Dependencies

- [Homebrew](https://brew.sh/)
- [Oh My Posh](https://ohmyposh.dev/)
- [Vivid](https://github.com/sharkdp/vivid)
- [Fira Code Nerd Font](https://www.nerdfonts.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Node.js](https://nodejs.org/en/) - Not installed by install scripts. I use [NVM](https://github.com/nvm-sh/nvm) as version manager at the moment. I am considering switching to [Fast Node Manager(fnm)](https://github.com/Schniz/fnm), but haven't commited yet.
- [asciinema](https://asciinema.org/)

### Language Servers
[Available language servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- [TypeScript/JavaScript](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver) - ```$ npm install -g typescript typescript-language-server ```
- [JSON](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls) - ```npm i -g vscode-langservers-extracted ```
- [HTML](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html) - ```npm i -g vscode-langservers-extracted ```
- [CSS](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls) - ```npm i -g vscode-langservers-extracted ```
- [Vue.js](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vuels) - ```npm install -g vls ```
- [bash](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls) - ```npm i -g bash-language-server ```
- [eslint](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint) - ```npm i -g vscode-langservers-extracted```

## Neovim plugins
### Visuals
- [mhinz/vim-startify](https://github.com/mhinz/vim-startify)
- [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline)
- [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)
- [morhetz/gruvbox](https://github.com/morhetz/gruvbox)
- [kyazdani42/nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons)

### Telescope stuff
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-telescope/telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim)
- [Plug 'nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)

### Language Server Protocol
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

### Treesitter
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### Autocompletion
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [onsails/lspkind-nvim](https://github.com/onsails/lspkind-nvim)

### Writing & Markdown
- [junegunn/goyo.vim](https://github.com/junegunn/goyo.vim)
- [junegunn/limelight.vim](https://github.com/junegunn/limelight.vim)
- [preservim/vim-markdown](https://github.com/preservim/vim-markdown)
- [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

### Tools
- [tpope/vim-surround](https://github.com/tpope/vim-surround])
- [bfrg/vim-jq](https://github.com/bfrg/vim-jq)

### Git
- [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive])

## Inspirations

- DJ Adams, all the way! - [His dotfiles](https://github.com/qmacro/dotfiles).
- ThePrimeagen - [His dotfiles](https://github.com/ThePrimeagen/.dotfiles)

### _bashrc.d_

I noticed DJ had split his bashrc into smaller scripts, and dynamically load them from bashrc.d. That is a great way to prevent bashrc to grow infinitely. I'm on board with it. 😃

### _.extrasrc_

Contains system specific configuration, like NVM, FNM, etc. This file is not tracked, and needs to be maintained per system.

Exports:
- BLOG_PATH=\<path to rikosjett.com\>
- WRITING_PATH=\<path to writing vault\>

## References (in no particular order)

- [Tmux plugin manager - tpm](https://github.com/tmux-plugins/tpm)

### Old setup based on

- Nathaniel Landaus blogpost ["My Mac OSX bash profile"](https://natelandau.com/my-mac-osx-bash_profile/).
- Corey Schafers YouTube video ["How I Setup a New Development Machine - Using Scripts to Automate Installs and Save Time"](https://www.youtube.com/watch?v=kIdiWut8eD8)
- Mathias Bynens dotfiles([Github](https://github.com/mathiasbynens/dotfiles))
- Sindre Sørhus Quicklook plugins ([Github](https://github.com/sindresorhus/quick-look-plugins))

> Make the terminal work for you! 🤓
