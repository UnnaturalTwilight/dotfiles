https://yalter.github.io/niri/Example-systemd-Setup.html

services that should autostart with niri can be enabled with:
```sh
systemctl --user add-wants niri.service example.service
```

Curently niri is set to want:

- elephant.service
- linux-id.service
- niri-autoselect-portal.service
- quickshell@niri-backdrop.service
- solaar.service
- tailscale-systray.service
- thunar.service
- thunderbird.service
- udiskie.service
