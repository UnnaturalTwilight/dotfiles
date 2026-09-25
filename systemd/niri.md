https://yalter.github.io/niri/Example-systemd-Setup.html

services that should autostart with niri can be enabled with:
```sh
systemctl --user add-wants niri.service example.service
```

Curently niri is set to want:

- elephant.service
- walker.service
- linux-id.service
- niri-autoselect-portal.service
- quickshell@niri-backdrop.service
- solaar.service
- tailscale-systray.service
- thunar.service
- thunderbird-headless.service
- udiskie.service

OpenTabletDriver is setup to auto-start when my tablet is pluged in.
My tablet is given the static node of `/dev/drawingtablet` using:

`/etc/udev/rules.d/90-huion-tablet.rules
```  
# Huion Kamvas 12
SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{product}=="Huion Tablet_GS1161", SYMLINK+="drawingtablet", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/drawingtablet"
```
