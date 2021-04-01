#!/usr/bin/env bash
dotfiles="$HOME/.dotfiles"

# Print figlet of section headers
heading () {
  figlet $@
}

# Symlink dotfiles
heading symbolic links
# Files
for i in bash_profile bashrc gitconfig; do
  echo $i
  ln -s -f "$dotfiles/$i" "$HOME/.$i"
done

# Directories
ln -s -f "$dotfiles/bashrc.d" "$HOME/.bashrc.d"

echo Symlinking done

