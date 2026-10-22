#
# $ZDOTDIR/violence.zsh
#

## local zsh configurations

export EDITOR=${EDITOR:="edit"}
export GPG_TTY=$(tty)

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  source $ZDOTDIR/kitty.zsh
fi

# local aliases
alias compose='docker compose'
