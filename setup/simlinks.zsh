#! /usr/bin/zsh
# Setup the simlinks between .config and this repo
builtin cd ~/dotfiles || exit 1

if [ -z "$ZDOTDIR" ]; then
  # ZDOTDIR is the only real thing we can check for this
  echo "\$ZDOTDIR is not set. Make sure to set up the system wide config first."
  exit 1
fi

# on zsh the var is HOST but on bash it is HOSTNAME
# but if all else fails just cat the file
host=${HOST:-$(cat /etc/hostname)}
# same goes for user
user=${USER:-$USERNAME}

## Create symlinks for bash
ln -sfbr --suffix=.bak --target-directory=$HOME ./bash/.bashrc
ln -sfbr --suffix=.bak --target-directory=$HOME ./bash/.bash_profile

## Create symlinks for zsh
mkdir -p $ZDOTDIR
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/.*
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/keybinds.zsh
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/kitty.zsh
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/$host.zsh

# Pull in the XDG vars
source $ZDOTDIR/.zshenv

# Make sure zsh reads $ZDOTDIR/.zshrc
mv $HOME/.zshrc $HOME/.zshrc.bak 2>/dev/null

# make a couple dirs that just need to exist
mkdir -p $XDG_STATE_HOME/bash
mkdir -p $XDG_STATE_HOME/zsh
mkdir -p $XDG_DATA_HOME/applications
mkdir -p $HOME/.local/bin

# Simple Links
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME ./starship.toml
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME ./hyfetch.json
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME ./fastfetch
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME ./kitty
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME ./msedit

# Assets (images, etc.)
ln -sfbr --suffix=.bak ./assets $XDG_CONFIG_HOME/assets
ln -sfbr --suffix=.bak $XDG_CONFIG_HOME/assets/${user}_profilepic.png $XDG_CONFIG_HOME/profilepic.png

# Yazi
mkdir $XDG_CONFIG_HOME/yazi
ln -sfbr --suffix=.bak --target-directory=$XDG_CONFIG_HOME/yazi ./yazi/*
cp -fLT --remove-destination ./yazi/package.toml $XDG_CONFIG_HOME/yazi/package.toml
if (command -pv ya); then
  echo
  ya pkg upgrade --discard
  echo
else
  echo
  echo "run ya pkg upgrade to install yazi plugins"
  echo
fi

# Desktop files
ln -sfbr --suffix=.bak --target-directory=$XDG_DATA_HOME/applications ./desktop/unicode-picker.desktop
ln -sfbr --suffix=.bak --target-directory=$XDG_DATA_HOME/applications ./desktop/vlc.desktop

# Scripts
ln -sfbr --suffix=.bak --target-directory=$HOME/.local/bin ./scripts/unicode-panel.sh

echo
echo "THIS SCRIPT IS WIP"
echo "All other links need to be created by hand"

# SDDM
echo
echo "Manualy add profile pic to /usr/share/sddm/faces as ${user}.face.icon to get it to show up in SDDM"
echo "sudo ln -s $XDG_CONFIG_HOME/profilepic.png /usr/share/sddm/faces/${user}.face.icon"
echo "sudo setfacl -m u:sddm:r /usr/share/sddm/faces/${user}.face.icon"
echo
