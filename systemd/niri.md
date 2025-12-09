
https://yalter.github.io/niri/Example-systemd-Setup.html

services that should autostart with niri can be enabled with:
```sh
systemctl --user add-wants niri.service example.service
```