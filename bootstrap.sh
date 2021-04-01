#!/usr/bin/env bash
dotfiles="$HOME/.dotfiles"

# Print figlet of section headers
heading () {
  figlet $@
}

# Symlink dotfiles
heading symbolic links
# Files
for i in bash_profile bashrc gitconfig vimrc; do
  # Remove old symlink
  if [ -f $HOME/.$i ]; then
    echo Removing old $HOME/.$i
    rm .$i
  fi
  # Add new symlink
  echo Adding new $HOME/.$i
  ln -s -f "$dotfiles/$i" "$HOME/.$i"
done

# Directories
if [ -d $HOME/.bashrc.d ]; then
  echo Removing old $HOME/.bashrc.d
  rm $HOME/.bashrc.d
fi
ln -s -f "$dotfiles/bashrc.d" "$HOME/.bashrc.d"

echo Symlinking done