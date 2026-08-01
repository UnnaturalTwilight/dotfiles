#
# $ZDOTDIR/violence.zsh
#

## local zsh configurations

export EDITOR=${EDITOR:="edit --goto"}

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  source $ZDOTDIR/kitty.zsh
fi

# local aliases
alias mini-fetch='hyfetch --distro arch_small --args="-c $XDG_CONFIG_HOME/fastfetch/mini.jsonc"'
alias fetch='fastfetch -c $XDG_CONFIG_HOME/fastfetch/moon.jsonc'
alias clf='clear; fastfetch -c $XDG_CONFIG_HOME/fastfetch/moon.jsonc'

alias run='systemd-run --user --'
alias compose='docker compose'

alias fzf-view='fzf --style full --preview "/usr/share/fzf/fzf-preview.sh {}" \
  --bind "focus:transform-header:file --brief {}" -m'

# Suffix Alias to auto bat .md files with just the filename
alias -s md='bat --italic-text=always'
