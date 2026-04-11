#! /bin/sh

# For syncing yazi's package.toml to ~/.config and updating plugins
# This is to avoid having the current hash of the plugin saved in this repo

# Know what dir we are in
builtin cd ~/dotfiles || exit 1

# Copy over this repo's package.toml, overwriting the one in ~/.config/yazi
cp -fLT --remove-destination ./yazi/package.toml $XDG_CONFIG_HOME/yazi/package.toml

# Remove the plugins or else `ya pkg upgrade` will refuse to run
rm --recursive --force --preserve-root $XDG_CONFIG_HOME/yazi/plugins/ $XDG_CONFIG_HOME/yazi/flavors/

# Run the upgrade
command ya pkg upgrade
