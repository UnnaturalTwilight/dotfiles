#
# $ZDOTDIR/wsl-arch.zsh
#

export EDITOR=${EDITOR:="edit"}

export GALLIUM_DRIVER=d3d12
export LIBVA_DRIVER_NAME=d3d12

# Clean up the mess WSL makes
path=( "${(@)path:#/bin}" )
path=( "${(@)path:#/sbin}" )
path=( "${(@)path:#/usr/sbin}" )
path=( "${(@)path:#*/games}" )
# add select windows apps to the path
path=($path ~/.local/bin/windowsapps ~/.local/bin/winget)

# Check if interop is working, since I rely on more than I should.
# This is a far from foolproof check but it does catch the case that provides the least helpful error message
if [[ ! -e /proc/sys/fs/binfmt_misc/WSLInterop ]] {
  print "\e[91mWSL interop is not working! Windows programs will not work\e[0m"
}

if [[ -n "$WT_SESSION" ]]; then
  # Windows Terminal

  #TODO: Windows Terminal now supports kitty keyboard protocol
  # Alt-Shift-C
  bindkey '^[C' copy-buffer-to-clipboard
  bindkey -M shift-select '^[C' shift-select::copy-region

  # Nerd fonts in less (For Kitty this is done in kitty.conf)
  export LESSUTFCHARDEF=E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p

  # Windows Terminal's bg colour makes the default fg=8 almost invisable
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
  DEJA_HIGHLIGHT_STYLE="fg=244"

  # Shell integration is based on:
  # https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration#bash
  # https://sw.kovidgoyal.net/kitty/shell-integration/

  function _wti_precmd() {
    # Exit code of last command, do not print when invoked from zle
    if ! builtin zle; then
      if [[ -n "$STARSHIP_CMD_STATUS" ]] {
        builtin print -n "\e]133;D;${STARSHIP_CMD_STATUS}\e\\"
      } else {
        builtin print -n "\e]133;D\e\\"
      }
    fi

    # Current working directory
    builtin local current_dir=$(wslpath -w "$PWD")
    builtin print -n "\e]9;9;$current_dir\e\\"

    if [[ -o prompt_percent ]]; then
      builtin typeset -g precmd_functions
      if [[ ${precmd_functions[-1]} == _wti_precmd ]] {
        builtin local mark1=$'%{\e]133;A\e\\%}'
        builtin local end1=$'%{\e]133;B\e\\%}'
        # This is safe to do when _wti_precmd is the last precmd function
        [[ $PS1 == *$mark1* ]] || PS1=${mark1}${PS1} # ${end1}
        # Windows Terminal doesn't support marking PS2 so long commands are prone to corruption
        # [[ $PS2 == *$mark2* ]] || PS2=${mark2}${PS2}
      } else {
        # Try to become the last precmd function
        precmd_functions=(${precmd_functions:#_wti_precmd} _wti_precmd)
        if ! builtin zle; then
          builtin print -n "\e]133;A\e\\"
        fi
      }
    elif ! builtin zle; then
      builtin print -n "\e]133;A\e\\"
    fi

    # Update terminal title
    builtin print -n "\e]2;"${(%):-%(4~|…/%3~|%~)}"\e\\"
  }

  function _wti_prexec() {
    # Start of command execution
    builtin print -n "\e]133;C\e\\"

    # Update terminal title
    builtin print -n "\e]2;"${(V)1}"\e\\"
  }

  precmd_functions+=(_wti_precmd)
  preexec_functions+=(_wti_prexec)

elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
  source "$(code --locate-shell-integration-path zsh)"
fi

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
