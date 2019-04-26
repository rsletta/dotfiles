#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
    # symlink dotfiles
    ln -sf "$PWD"/.bash_profile ~/.bash_profile
    ln -sf "$PWD"/.bashrc ~/.bashrc
    ln -sf "$PWD"/.git-completion.bash ~/.git-completion.bash
	ln -sf "$PWD"/.aliases ~/.aliases
	ln -sf "$PWD"/.functions ~/.functions
	ln -sf "$PWD"/.nvm_path ~/.nvm_path
	
	# Reload config
	if [[ "$OSTYPE" == "darwin"* ]]; then
		source ~/.bash_profile;
	elif [[ "$OSTYPE" == "linux-gnu" ]]; then
		# Bootstrap Ubuntu
		source ~/.bashrc;
	fi
	
	
	# Bootstrap environment
	read -p "Bootstrap environment? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		if [[ "$OSTYPE" == "darwin"* ]]; then
			# Bootstrap macOS
			./macOS.sh;
		elif [[ "$OSTYPE" == "linux-gnu" ]]; then
			# Bootstrap Ubuntu
			./Ubuntu.sh;
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