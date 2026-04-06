# .zshrc

HISTFILE=$XDG_STATE_HOME/zsh/histfile
HISTSIZE=100000
SAVEHIST=80000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS

setopt AUTO_RESUME

setopt AUTO_CD
bindkey -e

# Keybind
# autoload zkbd

# The following lines were added by compinstall
zstyle :compinstall filename '$ZDOTDIR/.zshrc'

autoload -Uz compinit

compinit
# End of lines added by compinstall

# help function
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn
alias help=run-help

# reload completions on pacman update
TRAPUSR1() { 
  rehash 
}

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

function yazi-cwd() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
compdef _yazi yazi-cwd
alias yazi='yazi-cwd'

## Binds
WORDCHARS=''
# I should up keybinds properly at some point but for now using the raw escape codes will do
# C-Left and C-Right for word jumping -- kitty sets these to alt-left and alt-right by default, this is just a copy of that code with the keycodes changed
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
# Ctrl-Backspace to delete word backwards
bindkey '^H' backward-delete-word
# Home and End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
# delete deletes forward
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' delete-word
# Undo on ctrl-z, redo on ctrl-shift-z
bindkey '^Z' undo
bindkey '^[[122;6u' redo

# Edit cmd buffer on Ctrl-e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

## Aliases
alias cd='z'
alias cdz='zi'
alias ls='eza -x --hyperlink --group-directories-first --icons=auto'
alias ll='eza -l --hyperlink --group-directories-first --icons=auto'
alias la='eza -la --hyperlink --group-directories-first --icons=auto'
alias tree='eza -lT --hyperlink --group-directories-first --icons=auto'
alias grep='grep --color=auto'

alias shutdown='shutdown now'
alias soft-reboot='systemctl soft-reboot'

alias makepkg="PACKAGER=${PACKAGER:=\"${(C)USER} <${USER}@${HOST}>\"} makepkg"

# Windows terminal reports itself as xterm-256color and doesn't set COLORTERM despite supporting truecolor
case "$TERM" in
    xterm-color|*-256color) export COLORTERM=truecolor;;
esac

# Prompt setup
autoload -Uz promptinit
promptinit

PROMPT='%n@%m %~ %F{white}%B%#%b%f '
RPROMPT='[%F{yellow}%?%f]'

if [[ -v COLORTERM ]]; then
  eval "$(starship init zsh)"
fi

# Load plugins

ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main brackets)

# Define styles for zsh-syntax-highlighting
# default styles can be found at: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=013,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=blue,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=037'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=209'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=209'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=209'
ZSH_HIGHLIGHT_STYLES[comment]='fg=008,italic'

# Load local configs if they exist
source $ZDOTDIR/$HOST.zsh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zoxide initialization
eval "$(zoxide init zsh)"
