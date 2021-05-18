#!/bin/sh

XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_CACHE_HOME=$HOME/.cache

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_CACHE_HOME

ZDOTDIR=$XDG_CONFIG_HOME/zsh
ZSH=$XDG_DATA_HOME/oh-my-zsh
DOTFILES=$XDG_DATA_HOME/dotfiles
ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh

do_it() {
    echo "Checking all the requirements are met..."
    need git
    need zsh
    need mkdir
    need chsh
    need ln

    clone_ohmyzsh
    clone_dotfiles
    copy_dotfiles
    set_cache_folder
    link_zshenv
    install_common_dependencies
    activate_zsh
}

clone_ohmyzsh() {
    echo
    echo "Installing Oh My Zsh..."

    OH_MY_ZSH_REPO="https://github.com/robbyrussell/oh-my-zsh.git"

    if git_repo "$ZSH"; then
        echo "Already a git repository: '$ZSH'"
    else
        ensure mkdir -p "$ZSH"
        ensure git clone --depth=1 "$OH_MY_ZSH_REPO" "$ZSH"
    fi
}

clone_dotfiles() {
    echo
    echo "Installing DotFiles..."

    DOTFILES_REPO="https://github.com/mgarciadelojo/dotfiles.git"

    if git_repo "$DOTFILES"; then
        echo "Already a git repository: '$DOTFILES'"
    else
        ensure mkdir -p "$DOTFILES"
        ensure git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES"
    fi
}

copy_dotfiles() {
    echo
    echo "Copying all the config files..."
	rsync \
        --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".editorconfig" \
		--exclude "brew.sh" \
		--exclude "install.sh" \
		--exclude "README.md" \
		-avh --no-perms $DOTFILES ~;
}

set_cache_folder() {
    # ensure ZSH cache dir exists
    [ -d $ZSH_CACHE_DIR ] || mkdir -p $ZSH_CACHE_DIR

    # set update marker
    touch $ZSH_CACHE_DIR/last-update
}

link_zshenv() {
	ZSHENV="$(readlink -sm "$ZDOTDIR/.zshenv")"

	if not_linked "$HOME/.zshenv" "$ZSHENV"; then
        echo
		echo "Creating symlink from '$HOME/.zshenv' to '$ZDOTDIR/.zshenv'..."
		ensure ln -fs "$ZSHENV" "$HOME/.zshenv"
	fi
}

install_common_dependencies() {
    echo
    echo "Installing Common Dependencies..."

    NVM_DIR=$XDG_CONFIG_HOME/.nvm
    GVM_DIR=$XDG_CONFIG_HOME/.gvm

    if git_repo "$NVM_DIR"; then
        echo "Already a git repository: '$NVM_DIR'"
    else
        pwd=$(pwd)
        ensure git clone https://github.com/nvm-sh/nvm.git $NVM_DIR
        cd $NVM_DIR
        latesttag=$(git describe --tags)
        ensure git checkout ${latesttag}
        cd $pwd

        echo "NVM ${latesttag} installed!"
    fi

    if git_repo "$GVM_DIR"; then
        echo "Already a git repository: '$GVM_DIR'"
    else
        ensure git clone https://github.com/nvm-sh/nvm.git $GVM_DIR

        echo "GVM installed!"
    fi
}

activate_zsh() {
    if [ "$(basename -- "$SHELL")" != "zsh" ]; then
        echo
        echo "Changing your default shell to zsh..."
        ensure as_root chsh -s $(grep "zsh$" /etc/shells | tail -1) "$USER"
    fi

    echo

    echo "ZSH Config is successfully installed!"
    echo "Log out and log in again to start using this config"
}

need() {
    if ! command -v "$1" > /dev/null 2>&1; then
        echo "need '$1' (command not found)"
        exit 1
    fi
}

git_repo() {
    [ -d "$1/.git" ]
}

not_linked() {
	[ "$(readlink -sm "$1")" != "$2" ]
}

ensure() {
	"$@"
	if [ $? != 0 ]; then
		echo "command failed: $*"
        exit 1
	fi
}

as_root() {
    if [ $(id -u) -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	do_it
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		do_it
	fi
fi
