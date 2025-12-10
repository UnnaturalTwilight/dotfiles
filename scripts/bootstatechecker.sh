#!/usr/bin/env bash
# Script to throw a couple of notifications if the system is not booted in a certain state.

# check mount state of windows partition
if findmnt -r | grep -q '/mnt/c'; then
    if findmnt -r -O ro | grep -q '/mnt/c'; then
        notify-send "C:/ is mounted read-only" "Windows may not have been fully shut down." --urgency=critical --app-name="Boot State Checker"
    fi 
else
    notify-send "C:/ is not mounted" "Apps that depend on data stored under windows will not work." --urgency=critical --app-name="Boot State Checker"
fi

if [[ "$1" == "debug" ]]; then
    notify-send "Debug Mode" "This is a test notification from bootstatechecker.sh" --urgency=normal --app-name="Boot State Checker"
    systemctl --user show-environment > ${HOME}/bsc_debug_sysd-user-env
    printenv > ${HOME}/bsc_debug_printenv
    zsh -c printenv > ${HOME}/bsc_debug_zsh-env
    sort ${HOME}/bsc_debug_sysd-user-env > ${HOME}/bsc_debug_sysd-user-env-sorted
    sort ${HOME}/bsc_debug_printenv > ${HOME}/bsc_debug_printenv-sorted
    sort ${HOME}/bsc_debug_zsh-env > ${HOME}/bsc_debug_zsh-env-sorted
    kitty --execute --detach kitten diff ${HOME}/bsc_debug_sysd-user-env-sorted ${HOME}/bsc_debug_printenv-sorted
    kitty --execute --detach kitten diff ${HOME}/bsc_debug_sysd-user-env-sorted ${HOME}/bsc_debug_zsh-env-sorted
fi

exit 0
# other checks