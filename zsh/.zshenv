typeset -U path PATH
path=(. ~/.local/bin ~/.cargo/bin ~/.cargo/env $path)
export PATH

# XDG Base Directories
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state


# Applications
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
export GNUPGHOME="$XDG_DATA_HOME"/gnupg # Needs manual editing to systemd user sockets. see arch wiki.
# Go
export GOPATH="$XDG_DATA_HOME"/go
# .NET
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
# Java
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
# NPM
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js   
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm                             
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
# Rust
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
