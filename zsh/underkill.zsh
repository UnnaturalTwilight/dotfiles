# local zsh configurations

KEYBOARD_HACK=\\

export EDITOR=edit

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  source $ZDOTDIR/kitty.zsh
  alias uni-copy='kitten unicode-input | tee >(wl-copy -n)'
fi

source <(niri completions zsh | sed "s/line\[2\]/line[1]/g; /'::command/d")

# local aliases
alias mnt-win='sudo ntfs-3g -o windows_names /dev/nvme0n1p3 /mnt/c'
alias reboot-win='systemctl reboot --boot-loader-entry=auto-windows'

alias mini-fetch='hyfetch --distro arch_small --args="-c $XDG_CONFIG_HOME/fastfetch/mini.jsonc"'
alias fetch='fastfetch -c $XDG_CONFIG_HOME/fastfetch/moon.jsonc'
alias clf='clear; fastfetch -c $XDG_CONFIG_HOME/fastfetch/moon.jsonc'

alias compose='docker compose'

alias vlc='env -u DISPLAY vlc' # run vlc in wayland
alias fzf-view='fzf --style full --preview "/usr/share/fzf/fzf-preview.sh {}" --bind "focus:transform-header:file --brief {}" -m'

# Suffix Alias to auto bat .md files with just the filename
alias -s md='bat --italic-text=always'

case $XDG_CURRENT_DESKTOP in
  Hyprland)
    # Hyprland aliases
    alias logout='hyprctl dispatch exit'
    alias run='hyprctl dispatch exec --'
    alias lock='hyprlock'
    ;;
  niri)
    alias logout='niri msg action quit --skip-confirmation'
    alias run='niri msg action spawn --'
    alias lock='qs --config niri-backdrop ipc call lock lock'
    alias qs-bg='qs --config niri-backdrop'
    ;;
  *)
    alias run='systemd-run --user --'
    ;;
esac

case $USER in
  cal)
    alias music-dl='wl-copy -c && wl-paste -w $XDG_CONFIG_HOME/scripts/music-dl-echo.sh'
    ;;
  sky)
    ;;
  *)
    ;;
esac

function copy-buffer-to-clipboard() {
  print -Rn "$BUFFER" | wl-copy
}
zle -N copy-buffer-to-clipboard
bindkey '^[[99;6u' copy-buffer-to-clipboard

function cut-buffer-to-clipboard() {
  print -Rn "$BUFFER" | wl-copy
  zle kill-buffer
}
zle -N cut-buffer-to-clipboard
bindkey '^[[120;6u' cut-buffer-to-clipboard

# plugin: zsh-autosuggestions, causes issues if loaded on remote hosts
if [[ -z "$SSH_TTY" && "$colourterm" == "yes" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
