#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# XDG Dirs
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=1000
HISTFILE=$HOME/.local/state/bash/histfile
shopt -s checkwinsize
shopt -s autocd

bind 'set show-all-if-unmodified on'

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# kitty integration
if test -n "$KITTY_INSTALLATION_DIR"; then
    # export KITTY_SHELL_INTEGRATION="enabled" # using no-rc mode so that it is possible to disable integration
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
    
    cleartoscrollback() { builtin printf "\e[H\e[22J"; }
    alias clear='cleartoscrollback'
    alias copycat='kitten clipboard'
    alias kdiff='kitten diff'
    alias icat='kitten icat'
    alias ssh='kitten ssh'
fi

# Windows Terminal reports itself as xterm-256color and doesn't set COLORTERM despite supporting truecolor
case "$TERM" in
    xterm-color|*-256color) export COLORTERM=truecolor;;
esac

if [ "$TERM" = "xterm-kitty" ] && [ -n "$SSH_TTY" ]; then
    alias edit='kitten edit-in-kitty'
else
    alias edit='nano'
fi

# Alias definitions.
alias ls='ls --color=auto --hyperlink=auto --group-directories-first --format=horizontal'
alias ll='ls -l --color=auto --hyperlink=auto --group-directories-first'
alias la='ls -lA --color=auto --hyperlink=auto --group-directories-first'

alias grep='grep --color=auto'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  if [ -f /etc/bash_completion.d/ ]; then
    . /etc/bash_completion.d
  fi
fi

# prompt
PS1='[\u@\h \W]\$ '

if [ -n "$COLORTERM" ]; then
    eval "$(starship init bash)"
fi
