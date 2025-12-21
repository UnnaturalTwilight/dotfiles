
# kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
    # export KITTY_SHELL_INTEGRATION="enabled" # using no-rc mode so that it is possible to disable integration
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

alias ssh='kitten ssh'
alias copycat='kitten clipboard'
alias uni-copy='kitten unicode-input | wl-copy -n'

# Save the screen to scrollback when clearing
cleartoscrollback() { builtin print -rn -- $'\r\e[0J\e[H\e[22J' >"$TTY"; }
alias clear='cleartoscrollback'