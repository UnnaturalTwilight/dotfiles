# local zsh configurations for WSL

# Clean up the mess WSL makes
path=( ${path[@]:#/bin} )
path=( ${path[@]:#/sbin} )
path=( ${path[@]:#/usr/sbin} )
path=( ${path[@]:#*/games} )
# add select windows apps to the path
path=($path ~/.local/bin/windowsapps ~/.local/bin/winget)

# Check if interop is working, since I rely on more than I should.
# This is a far from foolproof check but it does catch the case that provides the least helpful error message
cat /proc/sys/fs/binfmt_misc/WSLInterop &>/dev/null || echo "WSL interop is not working! Windows programs will not work" 

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  source $ZDOTDIR/kitty.zsh
  bindkey '^[[99;6u' copy-buffer-to-clipboard
  bindkey '^[[120;6u' cut-buffer-to-clipboard
elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
  source "$(code --locate-shell-integration-path zsh)"
else
  # Alt-Shift-C
  bindkey '^[C' copy-buffer-to-clipboard
  # Ctrl X
  bindkey '^X' cut-buffer-to-clipboard
fi

KEYBOARD_HACK=\\

export GALLIUM_DRIVER=d3d12
export LIBVA_DRIVER_NAME=d3d12
# eval "$(/usr/sbin/wsl2-ssh-agent)"

export EDITOR=edit

alias fetch='fastfetch -c $HOME/.config/fastfetch/moon.jsonc'
alias clf='clear; fastfetch -c $HOME/.config/fastfetch/moon.jsonc'

# Copy to clipboard
alias clip='/mnt/c/Windows/System32/clip.exe'

# Search windows path
function where-win() {
  for dir in ${(f)"$(where.exe $@ | sed 's|\r$||g' | sponge)"}; do
    wslpath $dir
  done
}
# Make where search linux then fallback to windows
function where() {
  builtin where $@ || where-win $@
}

# WSL windows path is very slow for zsh so this is my solution
# It works as a prefex like sudo
function run-win() {
  "$(wslpath "$(where.exe $1 | head -n 1)" | sed 's|\r$||')" $*[2,-1]
}

function copy-buffer-to-clipboard() {
  print -Rn "$BUFFER" | /mnt/c/Windows/System32/clip.exe 2>/dev/null
}
zle -N copy-buffer-to-clipboard

function cut-buffer-to-clipboard() {
  print -Rn "$BUFFER" | /mnt/c/Windows/System32/clip.exe 2>/dev/null
  zle kill-buffer
}
zle -N cut-buffer-to-clipboard

# plugin: zsh-autosuggestions, causes issues if loaded on remote hosts
if [[ -z "$SSH_TTY" && "$colourterm" == "yes" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
