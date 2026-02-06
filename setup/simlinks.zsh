#! /usr/bin/zsh
# Setup the simlinks between .config and this repo
cd ~/dotfiles || exit 1

if [ -z "$ZDOTDIR" ]; then
  # ZDOTDIR is the only real thing we can check for this
  echo "\$ZDOTDIR is not set. Make sure to set up the system wide config first."
  exit 1
fi

# on zsh the var is HOST but on bash it is HOSTNAME
# but if all else fails just cat the file
host=${HOST:=$(cat /etc/hostname)}

## Create symlinks for bash
ln -sfbr --suffix=.bak ./bash/.bashrc $HOME/.bashrc
ln -sfbr --suffix=.bak ./bash/.bash_profile $HOME/.bash_profile

## Create symlinks for zsh
mkdir -p $ZDOTDIR
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/.* 
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/kitty.zsh
ln -sfbr --suffix=.bak --target-directory=$ZDOTDIR ./zsh/$host.zsh

# Pull in the XDG vars
source $ZDOTDIR/.zshenv

# Make sure zsh reads $ZDOTDIR/.zshrc
mv $HOME/.zshrc $HOME/.zshrc.bak 2>/dev/null

# Fastfetch
ln -sfbr --suffix=.bak ./fastfetch $XDG_CONFIG_HOME/fastfetch
# assets (images, etc.)
ln -sfbr --suffix=.bak ./assets $XDG_CONFIG_HOME/assets
ln -sfbr --suffix=.bak $XDG_CONFIG_HOME/assets/$USER_profilepic.png $XDG_CONFIG_HOME/profilepic.png
echo "Manualy add profile pic to /usr/share/sddm/faces as $USER.face.icon to get it to show up in SDDM"
echo "sudo ln -s $XDG_CONFIG_HOME/profilepic.png /usr/share/sddm/faces/$USER.face.icon"
echo "sudo setfacl -m u:sddm:r /usr/share/sddm/faces/$USER.face.icon"

echo
echo "THIS SCRIPT IS WIP"
echo "All other links need to be created by hand"

# make a couple dirs that just need to exist
mkdir -p $XDG_STATE_HOME/bash
mkdir -p $XDG_STATE_HOME/zsh
mkdir -p $XDG_DATA_HOME/applications
mkdir -p $HOME/.local/bin