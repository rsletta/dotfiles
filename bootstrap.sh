#!/usr/bin/env bash
dotfiles="$HOME/.dotfiles"

# Print figlet of section headers
heading () {
  figlet $@
}

# Symlink dotfiles
heading symbolic links
# Files
for i in bash_profile bashrc gitconfig vimrc tmux.conf; do
  # Add new symlink
  echo Adding new $HOME/.$i
  ln -s -f -F "$dotfiles/$i" "$HOME/.$i"
done

# Directories
ln -s -f -F -h "$dotfiles/bashrc.d" "$HOME/.bashrc.d"

echo Symlinking done
