
# kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION=${KITTY_SHELL_INTEGRATION:="enabled"}
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

alias ssh='kitten ssh'
alias copycat='kitten clipboard'
alias uni-copy='kitten unicode-input | tee >(wl-copy -n)'
alias kdiff='kitten diff'
alias icat='kitten icat'

# Save the screen to scrollback when clearing
cleartoscrollback() { builtin print -rn -- $'\r\e[0J\e[H\e[22J' >"$TTY"; }
alias clear='cleartoscrollback'
