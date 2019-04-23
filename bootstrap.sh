#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function symlink() {
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
		bootstrap;
	fi;
}

function bootstrap() {
	if [ "`uname`" == "Darwin"] then
		# Bootstrap macOS
		sh macOS.sh
	elif [ "`uname`" == "Linux" ] then
		# Bootstrap Ubuntu
		sh Ubuntu.sh
	fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	symlink;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		symlink;
	fi;
fi;
unset symlink;
unset bootstrap;