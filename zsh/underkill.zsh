# local zsh configurations

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

# if [[ "$TERM" == "linux" && ! -v SSH_TTY ]]; then
#   # Set my color scheme
#   print -n -- "\e]P0000000\e]P1f14c4c\e]P223d18b\e]P3f5f543\e]P43b8eea\e]P5d670d6\e]P629b8db\e]P7e5e5e5"
#   print -n -- "\e]P8525252\e]P9cd3131\e]Pa0dbc79\e]Pbe5e510\e]Pc2472c8\e]Pdbc3fbc\e]Pe11a8cd\e]Pfffffff"
# fi
