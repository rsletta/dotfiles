# My personal dot file repository

This is the 2022 reboot of my dotfiles. Let's see where we end up.

The core principal behind this is to make it as platform independent as possible, with minimal configuration of the terminal application, to provide similar experience disregarding driving os.

I'm trying out using GNU Stow to manage my dotfiles, rather than using my hackety hacks bootstrapping scripts. This will probably be a bumpy ride, but isn't that part of what makes this fun?

macOS terminal client of choice is [iTerm 2](https://iterm2.com).
Ubuntu on Windows 10 runs through [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), with [Microsoft Terminal](https://github.com/Microsoft/Terminal).
On iOS I use [Blink Shell](https://blink.sh).

At the moment, I'm evaluating [Gruvbox](https://github.com/morhetz/gruvbox) as my color scheme. I used to use [Nord](https://www.nordtheme.com/), but my eyes are not what they used to, and I needed something new and contrasty.

## Dependencies

- [Homebrew](https://brew.sh/)
- [Oh My Posh](https://ohmyposh.dev/)
- [Vivid](https://github.com/sharkdp/vivid)
- [Caskaydia Cove Nerd Font](https://www.nerdfonts.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)

## Inspirations

- DJ Adams, all the way! - [His dotfiles](https://github.com/qmacro/dotfiles).
- ThePrimeagen - [His dotfiles](https://github.com/ThePrimeagen/.dotfiles)

### _bashrc.d_

I noticed DJ had split his bashrc into smaller scripts, and dynamically load them from bashrc.d. That is a great way to prevent bashrc to grow infinitely. I'm on board with it. 😃

## References (in no particular order)

- [Tmux plugin manager - tpm](https://github.com/tmux-plugins/tpm)

### Old setup based on

- Nathaniel Landaus blogpost ["My Mac OSX bash profile"](https://natelandau.com/my-mac-osx-bash_profile/).
- Corey Schafers YouTube video ["How I Setup a New Development Machine - Using Scripts to Automate Installs and Save Time"](https://www.youtube.com/watch?v=kIdiWut8eD8)
- Mathias Bynens dotfiles([Github](https://github.com/mathiasbynens/dotfiles))
- Sindre Sørhus Quicklook plugins ([Github](https://github.com/sindresorhus/quick-look-plugins))

> Make the terminal work for you! 🤓
