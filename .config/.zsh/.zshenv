# XDG variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Store ZSH files under XDG_CONFIG_HOME base directory.
# This works by symlinking ~/.zshenv to ~/.config/zsh/.zshenv (this file). See install.sh
export ZDOTDIR=$XDG_CONFIG_HOME/.zsh

# ZSH
export ZSH_CACHE_DIR=$XDG_CACHE_HOME/.zsh
export HISTFILE=$ZDOTDIR/.zhistory
