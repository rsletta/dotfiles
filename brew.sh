#!/usr/bin/env bash

# Install Homebrew
if [ $1 != "--brew-exist" ]; then
echo "Installing Homebrew first"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
echo "Make sure we’re using the latest Homebrew."
brew update

# Upgrade any already-installed formulae.
echo "Upgrade any already-installed formulae."
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install Bash 4.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install formulaes
brew install git 
brew install nvm
brew install tree
brew install neovim
if [ -d "~/.nvm"  ]; then
    echo "~/.nvm exists"
else 
    mkdir ~/.nvm
fi
brew install ranger


# Install casks
brew cask install iterm2 
brew cask install visual-studio-code
brew cask install tomighty 
brew cask install handbrake 
brew cask install spectacle 
brew cask install obs

# Install quickLook plugins
brew cask install qlcolorcode \
                  qlstephen \
                  qlmarkdown \
                  quicklook-json \
                  quicklook-csv \
                  qlimagesize \
                  betterzipql \
                  webpquicklook \
                  suspicious-package \
                  quicklookase \
                  qlvideo
                  
#Install fonts
brew tap homebrew/cask-fonts

# Install Fira Code
brew cash install font-fira-code

# Remove outdated versions from the cellar.
brew cleanup