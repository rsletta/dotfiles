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

# Install formulaes
brew install git \
             nvm \
             tree \
             ranger \
             tmux \
             neovim

# Setup NVM and install latest node.js LTS
if [ -d ~/.nvm  ]; then
    echo "~/.nvm exists"
    nvm install --lts
else 
    mkdir ~/.nvm
    nvm install --lts   
fi

# Set tmux config
ln -sf "$PWD"/configs/.tmux.conf ~/.tmux.conf

# Install casks
brew cask install iterm2 \
                  visual-studio-code \
                  brave-browser \
                  firefox \
                  google-chrome \
                  tomighty \
                  handbrake \
                  spectacle \
                  obs \
                  slack

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

# Reload .bash_profile / .bashrc
reload

# Add SAP NPM registry
npm config set @sap:registry https://npm.sap.com

# Install global nodeJS tools
npm install -g typescript nativescript yo eslint @ui5/cli @angular/cli @sap/cds @sap/generator-cds

# Config Visual Studio Code user settings
ln -sf "$PWD"/configs/vscode/settings.json $HOME/Library/Application Support/Code/User/settings.json

# Install Visual Studio Code extensions
code --install-extension johnpapa.angular-essentials
code --install-extension alexcvzz.vscode-sqlite  
code --install-extension christian-kohler.npm-intellisense 
code --install-extension dbaeumer.vscode-eslint
code --install-extension DotJoshJohnson.xml
code --install-extension eamodio.gitlens
code --install-extension HookyQR.beautify
code --install-extension PeterJausovec.vscode-docker
code --install-extension SAPSE.vsc-extension-mdk
code --install-extension Telerik.nativescript
code --install-extension tsvetan-ganev.nativescript-xml-snippets
code --install-extension zhouronghui.propertylist
