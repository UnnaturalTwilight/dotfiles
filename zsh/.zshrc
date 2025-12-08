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

fpath+=~/.config/zsh/func

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

# Aliases
alias cd='z'
# alias ls='ls --color=auto --hyperlink=auto --group-directories-first --format=horizontal'
alias ls='eza -x --hyperlink --group-directories-first --icons=auto'
alias ll='eza -l --hyperlink --group-directories-first --icons=auto'
alias la='eza -la --hyperlink --group-directories-first --icons=auto --mounts'
alias tree='eza -lT --hyperlink --group-directories-first --icons=auto'

alias grep='grep --color=auto'
alias run='hyprctl dispatch exec --'
alias lock='hyprlock'
alias shutdown='shutdown now'
alias soft-reboot='systemctl soft-reboot'
alias logout='hyprctl dispatch exit'

alias eww-test='eww -c ~/.config/eww_test'

alias mini-fetch='hyfetch --distro arch_small --args="-c $HOME/.config/fastfetch/mini.jsonc"'
alias fetch='fastfetch -c $HOME/.config/fastfetch/moon.jsonc'

alias vpn='windscribe-cli'
alias vlc='env -u DISPLAY vlc' # run vlc in wayland
alias yazi='yazi-cwd'

alias bzmenu='bzmenu --launcher walker'
alias compose='docker compose'

alias music-dl='wl-copy -c && wl-paste -w $HOME/.config/scripts/music-dl-echo.sh'
alias colour-ls='for i in {0..15}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+"\n"}; done;
		   echo; for i in {16..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'
alias path-ls='printenv PATH | sed "s/:/\n/g" | bat --style grid,numbers'

if [[ "$HOST" == "underkill" ]]; then
	alias mnt-win='sudo ntfs-3g -o windows_names /dev/nvme0n1p3 /mnt/c'
fi

# Kitten aliases
if [[ "$TERM" == "xterm-kitty" ]]; then
	alias ssh='kitten ssh'
	alias uni-copy='kitten unicode-input | wl-copy -n'
fi

autoload -Uz promptinit
promptinit

PROMPT='%n@%m %~ %F{white}%B%#%b%f '
RPROMPT='[%F{yellow}%?%f]'

autoload -Uz add-zsh-hook

function xterm_title_precmd () {
	print -Pn -- '\e]2;zsh %~\a'
}

function xterm_title_preexec () {
	print -Pn -- '\e]2;' && print -n -- "${(q)1}\a"
}

if [[ "$TERM" == (Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|screen*|wezterm*|tmux*|xterm*) ]]; then
	add-zsh-hook -Uz precmd xterm_title_precmd
	add-zsh-hook -Uz preexec xterm_title_preexec
fi

# load starship if it can render
if [[ "$COLORTERM" == "truecolor" ]]; then
# Transient prompt for starship: https://github.com/starship/starship/issues/888#issuecomment-2246272386
eval "$(starship init zsh)"
fi

# Load plugins

ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main brackets)

# Define styles for zsh-syntax-highlighting
# default styles can be found at: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='fg=magenta' #183
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta' #213
ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta' #177
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta' #176
ZSH_HIGHLIGHT_STYLES[precommand]='fg=013,bold' #199
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=blue,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=037'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=209'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=209'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=209'

if [[ "$HOST" == "underkill" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"
