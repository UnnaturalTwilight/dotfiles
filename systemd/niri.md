
https://yalter.github.io/niri/Example-systemd-Setup.html

services that should autostart with niri can be enabled with:
```sh
systemctl --user add-wants niri.service example.service
```

Curently niri is set to want:

- elephant.service
- ~~plasma-polkit-agent.service~~ > Replaced with quickshell
- quickshell@niri-backdrop.service
- solaar.service
- thunar.service
- thunderbird.service
- udiskie.service

