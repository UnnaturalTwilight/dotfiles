# local zsh configurations

export EDITOR=edit

# local aliases
alias mnt-win='sudo ntfs-3g -o windows_names /dev/nvme0n1p3 /mnt/c'
#alias lock='hyprlock'
alias logout='niri msg action quit'

alias run='niri msg action spawn-sh --'

alias mini-fetch='hyfetch --distro arch_small --args="-c $HOME/.config/fastfetch/mini.jsonc"'
alias fetch='fastfetch -c $HOME/.config/fastfetch/moon.jsonc'

#alias eww-test='eww -c ~/.config/eww_test'
alias bzmenu='bzmenu --launcher walker'
alias vlc='env -u DISPLAY vlc' # run vlc in wayland
alias vpn='windscribe-cli'

#alias music-dl='wl-copy -c && wl-paste -w $HOME/.config/scripts/music-dl-echo.sh'
alias uni-copy='kitten unicode-input | wl-copy -n'

# plugin: zsh-autosuggestions, causes issues if loaded on remote hosts
if [[ "$TERM" == "xterm-kitty" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
