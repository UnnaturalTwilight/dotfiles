#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HOST=$HOSTNAME

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=1000
HISTFILE=$HOME/.local/state/bash/histfile
shopt -s checkwinsize
shopt -s autocd

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# kitty integration
if test -n "$KITTY_INSTALLATION_DIR"; then
    # export KITTY_SHELL_INTEGRATION="enabled" # using no-rc mode so that it is possible to disable integration
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

case "$COLORTERM" in
    truecolor) color_prompt=yes;;
esac

if [ "$TERM" = "xterm-kitty" ] && [ -n "$SSH_TTY" ]; then
    alias edit='kitten edit-in-kitty'
    alias copycat='kitten clipboard'
else
    alias edit='nano'
fi

# Alias definitions.
alias ls='ls --color=auto --hyperlink=auto --group-directories-first --format=horizontal'
alias ll='ls -l --color=auto --hyperlink=auto --group-directories-first'
alias la='ls -lA --color=auto --hyperlink=auto --group-directories-first'

alias grep='grep --color=auto'

alias ..='cd ..'

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

if [ "$color_prompt" = yes ]; then
    eval "$(starship init bash)"
fi
unset color_prompt