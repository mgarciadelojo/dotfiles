# dotfiles
My personal dotfiles for Ubuntu and MacOS

# Getting started

The configuration is based on the following assumptions:

* `XDG_*` variables are set according to [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):
  + `XDG_CONFIG_HOME`: `~/.config`
  + `XDG_DATA_HOME`: `~/.local/share`
  + `XDG_CACHE_HOME`: `~/.cache`
* Some additional variables are set:
  + `ZDOTDIR`: `$XDG_CONFIG_HOME/zsh`
  + `ZSH`: `$XDG_DATA_HOME/oh-my-zsh`
  + `ZSH_CACHE_DIR`: `$XDG_CACHE_HOME/zsh`
* ZSH config files located under `$ZDOTDIR`.
* Oh My Zsh files located under `$ZSH`.
* `~/.zshenv` is a symbolic link pointing to `$ZDOTDIR/.zshenv`.

## Custom environment variables

To set custom (i.e., user- or machine-specific) environment variables or to override the defaults, use the file `$ZDOTDIR/custom.env`.

# Install
Run the following command in your terminal to install:

``` bash
$ bash <(curl -sSf https://raw.githubusercontent.com/mgarciadelojo/dotfiles/master/install.sh)
```
