# Lines configured by zsh-newuser-install
HISTFILE=$XDG_STATE_HOME/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -e
# End of lines configured by zsh-newuser-install

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

## Binds
WORDCHARS=''
# I should up keybinds properly at some point but for now using the raw escape codes will do
# C-Left and C-Right for word jumping -- kitty sets these to alt-left and alt-right by default, this is just a copy of that code with the keycodes changed
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
# Ctrl-Backspace to delete word backwards
bindkey '^H' backward-kill-word
bindkey '^[[1;5H' backward-kill-line
# Home and End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
# delete deletes forward
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word

## Aliases
alias cd='z'
alias ls='eza -x --hyperlink --group-directories-first --icons=auto'
alias ll='eza -l --hyperlink --group-directories-first --icons=auto'
alias la='eza -la --hyperlink --group-directories-first --icons=auto'
alias tree='eza -lT --hyperlink --group-directories-first --icons=auto'
alias grep='grep --color=auto'

alias shutdown='shutdown now'
alias soft-reboot='systemctl soft-reboot'

alias yazi='yazi-cwd'

alias colour-ls='for i in {0..15}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+"\n"}; done;
			echo; for i in {16..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'
alias path-ls='printenv PATH | sed "s/:/\n/g" | bat --style grid,numbers'

# Prompt setup
autoload -Uz promptinit
promptinit

PROMPT='%n@%m %~ %F{white}%B%#%b%f '
RPROMPT='[%F{yellow}%?%f]'

# load starship if truecolor terminal
if [[ "$COLORTERM" == "truecolor" ]]; then
  colourterm=yes
elif [[ "$TERM" == (*-256color|xterm-color) ]]; then
  colourterm=yes
fi

if [[ "$colourterm" == "yes" ]]; then
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

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load local configs if they exist
source $ZDOTDIR/$HOST.zsh

# zoxide initialization
eval "$(zoxide init zsh)"