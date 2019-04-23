#!/usr/bin/env bash

# Bootstrap macOS environment

# Install Homebrew?
read -p "Install Homebrew first? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
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
brew install bash \
             bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install formulaes
brew install git \
             nvm \
             tree \
             ranger \
             neovim

# Setup NVM and install latest node.js LTS
if [ -d "~/.nvm"  ]; then
    echo "~/.nvm exists"
    nvm install --lts
else 
    mkdir ~/.nvm
    nvm install --lts   
fi

# Install casks
brew cask install iterm2 \
                  visual-studio-code \
                  brave-browser \
                  firefox \
                  google-chrome \
                  tomighty \
                  handbrake \
                  spectacle \
                  obs

# Install quickLook plugins
brew cask install qlcolorcode \
                  qlstephen \
                  qlmarkdown \
                  quicklook-json \
                  quicklook-csv \
                  qlimagesize \
                  webpquicklook \
                  suspicious-package \
                  qlvideo

#Install fonts
brew tap homebrew/cask-fonts

# Install Fira Code
brew cask install font-fira-code

# Remove outdated versions from the cellar.
brew cleanup