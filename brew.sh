#!/usr/bin/env bash

# Make sure latest Homebrew is used
which -s brew
if [[ $? != 0 ]] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    brew update
    brew upgrade
fi

BREW_PREFIX=$(brew --prefix)

# Install GNU `sed`, overwriting built-in `sed`
brew install gnu-sed --with-default-names

# Install other packages
brew install nvm

# Install cask packages
brew install --cask \
    appcleaner \
    authy \
    bitwarden \
    brave-browser \
    docker \
    iterm2 \
    monitorcontrol \
    sequel-ace \
    signal \
    spotify \
    visual-studio-code
