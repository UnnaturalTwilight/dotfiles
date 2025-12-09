# local zsh configurations

# kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
    # export KITTY_SHELL_INTEGRATION="enabled" # using no-rc mode so that it is possible to disable integration
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

export EDITOR=edit

source <(niri completions zsh | sed "s/line\[2\]/line[1]/g; /'::command/d")

# local aliases
alias mnt-win='sudo ntfs-3g -o windows_names /dev/nvme0n1p3 /mnt/c'

alias mini-fetch='hyfetch --distro arch_small --args="-c $HOME/.config/fastfetch/mini.jsonc"'
alias fetch='fastfetch -c $HOME/.config/fastfetch/moon.jsonc'

alias compose='docker compose'

alias bzmenu='bzmenu --launcher walker'
alias vlc='env -u DISPLAY vlc' # run vlc in wayland

case $XDG_CURRENT_DESKTOP in
  Hyprland)
    # Hyprland aliases
    alias logout='hyprctl dispatch exit'
    alias run='hyprctl dispatch exec --'
    alias lock='hyprlock'
    # Eww test alias
    alias eww-test='eww -c ~/.config/eww_test'
    ;;
  niri)
    alias logout='niri msg action quit'
    alias run='systemd-run --user --'
    alias lock='hyprlock'
    ;;
  *)
    alias run='systemd-run --user --'
    ;;
esac

case $USER in
  cal)
    alias music-dl='wl-copy -c && wl-paste -w $HOME/.config/scripts/music-dl-echo.sh'
    ;;
  sky)
    ;;
  *)
    ;;
esac

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh='kitten ssh'
  alias copycat='kitten clipboard'
  alias uni-copy='kitten unicode-input | wl-copy -n'

  # Save the screen to scrollback when clearing
  cleartoscrollback() { builtin print -rn -- $'\r\e[0J\e[H\e[22J' >"$TTY"; }
  alias clear='cleartoscrollback'

fi



# plugin: zsh-autosuggestions, causes issues if loaded on remote hosts
if [[ -z "$SSH_TTY" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
