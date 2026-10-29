#
# $ZDOTDIR/underkill.zsh
#

export EDITOR=${EDITOR:="edit"}

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]] {
  function uni-copy() {
    kitten unicode-input | tee >(wl-copy -n)
  }

  # This assumes that kitty is set up as the difftool in git
  alias kdiff-git='git difftool --no-symlinks --dir-diff'
  alias pacdiff='sudo DIFFPROG=${DIFFPROG:="kitten diff"} pacdiff'
}

# Extra completions
source <(niri completions zsh | sed "s/line\[2\]/line[1]/g; /'::command/d")

# Local aliases
alias mnt-win='sudo ntfs-3g -o windows_names,special_files=wsl /dev/nvme0n1p3 /mnt/c'
alias reboot-win='systemctl reboot --boot-loader-entry=auto-windows'

alias mini-fetch='hyfetch --distro arch_small --args="-c $XDG_CONFIG_HOME/fastfetch/mini.jsonc"'

alias music-dl='wl-copy -c && wl-paste -w $XDG_CONFIG_HOME/scripts/music-dl-echo.sh'

function screen-record() {
  gpu-screen-recorder -w portal -a default_output \
    -restore-portal-session yes -df yes \
    -o "$HOME/Videos/Screencapture/Video_$(date +%Y-%m-%d_%H-%M-%S).mp4" "$@"
}

case $XDG_CURRENT_DESKTOP in
  niri)
    alias logout='niri msg action quit --skip-confirmation'
    alias lock='qs --config niri-backdrop ipc call lock lock'
    alias qs-bg='qs --config niri-backdrop'
    ;;
  *)
    ;;
esac
