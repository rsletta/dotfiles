#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
    # symlink dotfiles
    ln -sf "$PWD"/.bash_profile ~/.bash_profile
    ln -sf "$PWD"/.bashrc ~/.bashrc
    ln -sf "$PWD"/.git-completion.bash ~/.git-completion.bash
	ln -sf "$PWD"/.aliases ~/.aliases
	source ~/.bash_profile;
	
	# Bootstrap environment
	read -p "Bootstrap environment? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		if [[ "$OSTYPE" == "darwin"* ]]; then
			# Bootstrap macOS
			bash macOS.sh;
		elif [[ "$OSTYPE" == "linux-gnu" ]]; then
			# Bootstrap Ubuntu
			bash Ubuntu.sh;
		fi
	fi;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;