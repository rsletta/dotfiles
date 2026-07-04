# My personal dot file repository

It's that time again, and this is the Late 2024 reboot of my dotfiles. Let's see where we end up this time.

The core principle behind this was to make it as platform independent as possible, with minimal configuration of the terminal application, to provide similar experience disregarding driving os. I have since realized that this was over complicating things, and this time around I will start by tearing it all down, and build it up again, with a focus on macOS which is my primary development environment. While is still use Linux on all servers, I do see that the need for an overly complex setup is not there. To serve the needs there, I will rather look into a more minimal setup that I can pull in there when needed.

While I still want to try out using GNU Stow to manage my dotfiles, rather than using my hackety hacks bootstrapping scripts, I will start by manually sourcing stuff in. This will probably be a bumpy ride, but isn't that part of what makes this fun?

~macOS terminal client of choice is still [iTerm 2](https://iterm2.com).~
I have changed terminal client this time around and started using [Wez's Terminal Emulator(wezterm)](https://wezfurlong.org/wezterm/), which is using lua for [configuration](./wezterm).
On iOS I use [Blink Shell](https://blink.sh), when ssh'ing into the Linux servers.

I've now settled on [Tokyo Night](https://github.com/folke/tokyonight.nvim) (the `night` variant) across the whole stack. I used to run [Gruvbox](https://github.com/morhetz/gruvbox), and before that [Nord](https://www.nordtheme.com/), but my eyes are not what they used to be and I needed something contrasty. I looked at [catppuccin](https://catppuccin.com) — it looks nice but I couldn't get the right feel for it. Tokyo Night's `night` variant pairs a near-black background with bright, saturated syntax colors, which is easy on the eyes while keeping code legible.

## Zsh
I use `zsh`, since that is the default on macOS. I can't say I'm a very advanced user, so I look more to the usability of the shell, rather than pure features. I don't track my `.zshrc`, but rather source my [config](./config) in it, so I can make local customizations.

```bash
for rcfile in "$HOME"/.config/dotfiles/config/*.sh(N); do
    # Check if the file is the aliases file
    if [[ "$rcfile" == 60-aliases.sh ]]; then
        export ALIAS_FILE="$rcfile"
    fi
    source "$rcfile"
done
```

I tried `fish` when installing [CachyOS](https://cachyos.org) linux, which uses it as default. I liked some of the features it had, so I'm borrowing some ideas from [their zsh config](https://github.com/CachyOS/cachyos-zsh-config/blob/master/cachyos-config.zsh) for "fish like syntax highlighting and autosuggestions". I also use history substring search. These are added manually to my `.zshrc`.


```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting
echo "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
```
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-autosuggestions
echo "source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
```
```bash
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh-history-substring-search
echo "source ~/.zsh-history-substring-search/zsh-history-substring-search.zsh" >> ~/.zshrc
```
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
- [Starship](https://starship.rs/) — prompt

### Language Servers
[Available language servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
Reference the language server plugin setup for references to the different language servers.

## Neovim plugins

Managed with [lazy.nvim](https://github.com/folke/lazy.nvim) — each plugin lives in its own file under [`nvim/lua/config/plugins/`](./nvim/lua/config/plugins). See [docs/neovim.md](./docs/neovim.md) for the current plugin list, theme, and keymaps.

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
