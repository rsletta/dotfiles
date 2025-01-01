# My personal dot file repository

It's that time again, and this is the Late 2024 reboot of my dotfiles. Let's see where we end up this time.

The core principle behind this was to make it as platform independent as possible, with minimal configuration of the terminal application, to provide similar experience disregarding driving os. I have since realized that this was over complicating things, and this time around I will start by tearing it all down, and build it up again, with a focus on macOS which is my primary development environment. While is still use Linux on all servers, I do see that the need for an overly complex setup is not there. To serve the needs there, I will rather look into a more minimal setup that I can pull in there when needed.

While I still want to try out using GNU Stow to manage my dotfiles, rather than using my hackety hacks bootstrapping scripts, I will start by manually sourcing stuff in. This will probably be a bumpy ride, but isn't that part of what makes this fun?

~macOS terminal client of choice is still [iTerm 2](https://iterm2.com).~
I have changed terminal client this time around and started using [Wez's Terminal Emulator(wezterm)](https://wezfurlong.org/wezterm/), which is using lua for [configuration](./wezterm).
On iOS I use [Blink Shell](https://blink.sh), when ssh'ing into the Linux servers.

At the moment, I have been using [Gruvbox](https://github.com/morhetz/gruvbox) as my color scheme for some time. I've also used to use [Nord](https://www.nordtheme.com/), but my eyes are not what they used to, and I needed something new and contrasty. I had a quick look at [catppucin](https://catppuccin.com), and while it looks nice, I couldn't quite get the right feel for it. I might revisit it later, but I still search for the a color scheme that both looks good, and is easy on the eyes contrast wise.

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
- [Homebrew](https://brew.sh/)(macOS)
- [Oh My Posh](https://ohmyposh.dev/)

## Oh My Posh Theme
I used to run a minimalistic theme(that requires Nerd Fonts) I've called "[Oh My Gruvbox](./oh-my-posh)", inspired by several of the [existing minimal themes](https://ohmyposh.dev/docs/themes). It was a work in progress, with color palette from [morhetz/gruvbox](https://github.com/morhetz/gruvbox).

I have not landed on a new one yet, so I'll keep this for reference for now. The new WIP is the one called "oh-my-rikosjett".

### Language Servers
[Available language servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
Reference the language server plugin setup for references to the different language servers.

## Neovim plugins

I used to run all of these in my old config. I'll keep this for reference for the moment, but to see what I actually run, it is easier to just look into my [neovim config](./nvim/lua/config).
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
- [hrsh7th/cmp-emoji](https://github.com/hrsh7th/cmp-emoji)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [onsails/lspkind-nvim](https://github.com/onsails/lspkind-nvim)
- [ray-x/cmp-treesitter](https://github.com/ray-x/cmp-treesitter)
- [David-Kunz/cmp-npm](https://github.com/David-Kunz/cmp-npm)

### Writing & Markdown
- [junegunn/goyo.vim](https://github.com/junegunn/goyo.vim)
- [junegunn/limelight.vim](https://github.com/junegunn/limelight.vim)
- [preservim/vim-markdown](https://github.com/preservim/vim-markdown)
- [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [godlygeek/tabular](https://github.com/godlygeek/tabular)

### Tools
- [tpope/vim-surround](https://github.com/tpope/vim-surround])
- [bfrg/vim-jq](https://github.com/bfrg/vim-jq)

### Git
- [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive])

## Inspirations

- DJ Adams, all the way! - [His dotfiles](https://github.com/qmacro/dotfiles).
- ThePrimeagen - [His dotfiles](https://github.com/ThePrimeagen/.dotfiles)

### _bashrc.d_

I noticed DJ had split his bashrc into smaller scripts, and dynamically load them from bashrc.d. That is a great way to prevent bashrc to grow infinitely. I'm on board with it.  😃

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
