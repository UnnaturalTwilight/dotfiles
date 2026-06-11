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
cat /proc/sys/fs/binfmt_misc/WSLInterop &>/dev/null ||
  echo "\e[91mWSL interop is not working! Windows programs will not work\e[0m" 

# Kitty-specific aliases and functions, dependent shell integration // kittens
# Making the assumption that if we're in kitty, the shell integration is loaded
if [[ "$TERM" == "xterm-kitty" ]]; then
  source $ZDOTDIR/kitty.zsh
elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
  source "$(code --locate-shell-integration-path zsh)"
else
  # It should be safe to assume that the terminal is Windows Terminal if neither of the above are true for WSL
  # Alt-Shift-C
  bindkey '^[C' copy-buffer-to-clipboard
  bindkey -M shift-select '^[C' shift-select::copy-region
  # Ctrl X
  bindkey '^X' cut-buffer-to-clipboard

  function _windows-terminal-integration() {
    # Exit code of last command
    if [[ -n "$STARSHIP_CMD_STATUS" ]]; then
      builtin echo -ne "\e]133;D;${STARSHIP_CMD_STATUS}\e\\"
    else
      builtin echo -ne "\e]133;D\e\\"
    fi
    # current working directory
    printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"
    # Start of prompt
    builtin echo -ne "\e]133;A\e\\"
  }

  function _windows-terminal-integration-prexec() {
    # Start of command execution
    builtin echo -ne "\e]133;C\e\\"
  }

  # Because of how starship works on zsh this is valid
  # PROMPT="${PROMPT}"$'\e]133;B\e\\'

  precmd_functions+=(_windows-terminal-integration)
  preexec_functions+=(_windows-terminal-integration-prexec)
  
  # Windows Terminal's bg colour makes the default fg=8 almost invisable
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
fi

export GALLIUM_DRIVER=d3d12
export LIBVA_DRIVER_NAME=d3d12

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
