#!/usr/bin/env bash

git pull origin main;

XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_CACHE_HOME=$HOME/.cache

ZDOTDIR=$XDG_CONFIG_HOME/zsh
ZSH=$XDG_DATA_HOME/oh-my-zsh
ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	do_it
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		do_it
	fi
fi

do_it() {
    clone_ohmyzsh
    copy_dotfiles
    set_cache_folder
    link_zshenv
    install_common_dependencies
    bye
}

clone_ohmyzsh() {
    echo "Installing Oh My Zsh..."

    OH_MY_ZSH_REPO="https://github.com/robbyrussell/oh-my-zsh.git"

    if git_repo "$ZSH"; then
        echo "Already a git repository: '$ZSH'"
    else
        ensure mkdir -p "$ZSH"
        ensure git clone --depth=1 "$OH_MY_ZSH_REPO" "$ZSH"
    fi
}

copy_dotfiles() {
	rsync \
        --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".editorconfig" \
		--exclude "brew.sh" \
		--exclude "install.sh" \
		--exclude "README.md" \
		-avh --no-perms . ~;
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
		echo "Creating symlink from '$HOME/.zshenv' to '$ZDOTDIR/.zshenv'..."
		ensure ln -fs "$ZSHENV" "$HOME/.zshenv"
	fi
}

install_common_dependencies() {
    echo "Installing Common Dependencies..."

    NVM_DIR=$XDG_CONFIG_HOME/.nvm
    GVM_DIR=$XDG_CONFIG_HOME/.gvm

    if git_repo "$NVM_DIR"; then
        echo "Already a git repository: '$NVM_DIR'"
    else
        ensure git clone --quiet https://github.com/nvm-sh/nvm.git $NVM_DIR
        ensure latesttag=$(git describe --tags --git-dir=$NVM_DIR)
        ensure git checkout ${latesttag} --git-dir=$NVM_DIR

        echo "NVM ${latesttag} installed!"
    fi

    if git_repo "$GVM_DIR"; then
        echo "Already a git repository: '$GVM_DIR'"
    else
        ensure git clone --quiet https://github.com/nvm-sh/nvm.git $GVM_DIR

        echo "GVM installed!"
    fi




    echo "Installing NVM ${latesttag}"

    git clone https://github.com/nvm-sh/nvm.git $NVM_DIR
    latesttag=$(git describe --tags --git-dir=$NVM_DIR)
    git checkout ${latesttag}
    echo "Installing NVM ${latesttag}"


}

change_to_zsh() {
    if [ "$(shell)" != "zsh" ]; then
        echo "Changing your default shell to zsh..."
        ensure as_root chsh -s $(grep "zsh$" /etc/shells | tail -1) "$USER"
    fi
}

bye() {
    echo "ZSH Config is successfully installed!"
    echo "Log out and log in again to start using this config"
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
