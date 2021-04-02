# My personal dot file repository
This is rebooted with a clean slate. Let's see where we end up.

The core principal behind this is to make it as platform independent as possible, with minimal configuration of the terminal application, to provide similar experience disregarding driving os.

macOS terminal client of choice is [iTerm 2](https://iterm2.com), with [Kitty](https://sw.kovidgoyal.net/kitty/) on trial.
Ubuntu on Windows 10 runs through [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), with [Microsoft Terminal](https://github.com/Microsoft/Terminal).
On iOS I use [Blink Shell](https://blink.sh).

At the moment, I'm trying out the theme [Nord](https://www.nordtheme.com).
## Dependencies
Most dependencies are handled by configurations and the post-install scripts.
* [Nord theme for iTerm 2](https://github.com/arcticicestudio/nord-iterm2)
* [Nord theme for Blink Shell](https://github.com/hwyncho/Nord-Blink)
## Inspirations
DJ Adams, all the way! [His dotfiles](https://github.com/qmacro/dotfiles).

### *bashrc.d*
I noticed DJ had split his bashrc into smaller scripts, and dynamically load them from bashrc.d. That is a great way to prevent bashrc to grow infinitely. I'm on board with it. 😃

## References (in no particular order)
* [Nord Theme](https://www.nordtheme.com)
  * [Nord Vim](https://www.nordtheme.com/ports/vim)
  * [Nord VS Code](https://www.nordtheme.com/ports/visual-studio-code)
  * [Nord iTerm 2](https://github.com/arcticicestudio/nord-iterm2)
  * [Nord Tmux](https://www.nordtheme.com/docs/ports/tmux/installation)
  * [Nord Blink Shell](https://github.com/hwyncho/Nord-Blink)
  * [Nord Kitty](https://github.com/connorholyday/nord-kitty)
* [Tmux plugin manager - tpm](https://github.com/tmux-plugins/tpm)
* [Kitty terminal](https://sw.kovidgoyal.net/kitty/)

### Old setup based on
* Nathaniel Landaus blogpost ["My Mac OSX bash profile"](https://natelandau.com/my-mac-osx-bash_profile/).
* Corey Schafers YouTube video ["How I Setup a New Development Machine - Using Scripts to Automate Installs and Save Time"](https://www.youtube.com/watch?v=kIdiWut8eD8)
* Mathias Bynens dotfiles([Github](https://github.com/mathiasbynens/dotfiles))
* Sindre Sørhus Quicklook plugins ([Github](https://github.com/sindresorhus/quick-look-plugins))


> Make the terminal work for you! 🤓
