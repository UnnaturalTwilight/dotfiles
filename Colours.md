# Colours


# Existing colours:

## Eww

| Colour       | Hex                                                                                                     | also used in          |
| ------------ | ------------------------------------------------------------------------------------------------------- | --------------------- |
| Pinkish      | #D35D6E                                                                                               |                       |
| Navy         | #38384d                                                                                               |                       |
| Bar Gray     | #4e4e4e                                                                                               |                       |
| Kinda Gray   | #b0b4bc                                                                                               | dunstrc - frame color |
| BG Light     | #55505A                                                                                               |                       |
| BG Dark      | #414145                                                                                               |                       |
| Gradient     | `linear-gradient(90deg, rgba(50, 0, 90, 0.5) 20%, rgba(15, 20, 90, 0.5) 50%, rgba(50, 0, 90, 0.5) 80%)` |                       |
| Not Gradient | `rgba(15, 20, 90, 0.9)`                                                                                 |                       |

## Walker
Based on fluent design / powertoys run

| Variable | Hex |
|----------|----------|
| window_bg_color | #1f1f1f |
| accent_bg_color | #333333 |
| theme_fg_color | #d6d6d6 |
| error_bg_color | #3b0509 |
| error_fg_color | #dc626d |

## Hyprland

| Colour                | Used in                        | Hex (original)          |
| --------------------- | ------------------------------ | ----------------------- |
| Active Border         | hyprland.conf - general, group | #ffccddee #9900ffee |
| Inactive Border       | hyprland.conf - general, group | #595959aa             |
| Shadow                | hyprland.conf - decoration     | #1a1a1aee             |
| Special Workspace     | hyprland.conf - windowrule     | #9900ffee #ffccddee |
| XWayland Apps         | hyprland.conf - windowrule     | #D35D6Eee #D35D6Eaa |
| Pinned Apps           | hyprland.conf - windowrule     | #007ACCee #007ACCaa |
| Modal                 | hyprland.conf - windowrule     | #fca17dee #fca17daa |
| Group Locked Active   | hyprland.conf - group          | #9900ffee #ffccddee |
| Group Locked Inactive | hyprland.conf - group          | #080b10aa             |

### Hyprlock

| Colour            | Used in       | Hex (original) |
| ----------------- | ------------- | -------------- |
| Input Field Outer | hyprlock.conf | #9A348Eff    |
| Input Field Inner | hyprlock.conf | #ffffffff    |
| Input Field Font  | hyprlock.conf | #000000ff    |
| Check             | hyprlock.conf | #6BBD8fff    |
| Fail              | hyprlock.conf | #DA4C60ff    |
| Capslock          | hyprlock.conf | #FCA17Dff    |
| Background        | hyprlock.conf | rgba(50,0,90,0.8)  |
| Text              | hyprlock.conf | #ffffffff    |



## Dunst

| Colour              | Hex (original) | Used in                    |
| ------------------- | -------------- | -------------------------- |
| Frame               | #b0b4bcD0    | dunstrc - global           |
| Low Background      | #222222D0    | dunstrc - urgency_low      |
| Low Foreground      | #888888ff    | dunstrc - urgency_low      |
| Normal Background   | #285577D0    | dunstrc - urgency_normal   |
| Normal Foreground   | #ffffffff    | dunstrc - urgency_normal   |
| Critical Background | #900000D0    | dunstrc - urgency_critical |
| Critical Foreground | #ffffffff    | dunstrc - urgency_critical |
| Critical Frame      | #ff0000D0    | dunstrc - urgency_critical |

## Kitty

| Color Component               | Hex Value |
|-------------------------------|-----------|
| Foreground                    | #cccccc |
| Background                    | #1e1e1e |
| Selection Foreground          | #cccccc |
| Selection Background          | #264f78 |
| Cursor                        | #ffffff |
| Active Border Color           | #e7e7e7 |
| Inactive Border Color         | #414140 |
| Active Tab Foreground         | #ffffff |
| Active Tab Background         | #3a3d41 |
| Inactive Tab Foreground       | #858485 |
| Inactive Tab Background       | #1e1e1e |
| Color0                        | #1e1e1e |
| Color1                        | #f14c4c |
| Color2                        | #23d18b |
| Color3                        | #f5f543 |
| Color4                        | #3b8eea |
| Color5                        | #d670d6 |
| Color6                        | #29b8db |
| Color7                        | #e5e5e5 |
| Color8                        | #666666 |
| Color9                        | #cd3131 |
| Color10                       | #0dbc79 |
| Color11                       | #e5e510 |
| Color12                       | #2472c8 |
| Color13                       | #bc3fbc |
| Color14                       | #11a8cd |
| Color15                       | #ffffff |

## yazi - Catppuccin Mocha

The Catppuccin Mocha color scheme includes the following components:

| Component          | Hex Value |
|--------------------|-----------|
| Background         | #1E1E2E   |
| Current Line       | #2A273F   |
| Selection          | #F5D8FF   |
| Foreground         | #D9E0EE   |
| Comment            | #6A6A7A   |
| Red                | #F38BA8   |
| Green              | #A6E3A1   |
| Yellow             | #F9E2AF   |
| Blue               | #89B4FA   |
| Magenta            | #F5C2E7   |
| Cyan               | #94E2D5   |
| Orange             | #F9E2AF   |

For more details, refer to the [README.md](README.md) in the Catppuccin Mocha flavor directory.

## Zsh Syntax Highlighting

| Element | Hex | Style |
|---------|-----|-------|
| Unknown Token          | fg=red |
| Command                | fg=magenta |
| Alias                  | fg=magenta |
| Builtin                | fg=magenta |
| Function               | fg=magenta |
| Precommand             | fg=013,bold |
| Path                   | fg=blue |
| Autodirectory          | fg=blue,underline |
| Reserved Word          | fg=037 |
| Double-quoted Argument | fg=209 |
| Dollar-quoted Argument | fg=209 |
| Single-quoted Argument | fg=209 |

## Starship

| Colour | Hex    | Used in          |
| ------ | ------ | ---------------- |
| zero   | #9A348E | os, shell, sudo, username, hostname |
| one    | #DA627D | directory |
| two    | #FCA17D | git_branch, git_status, git_commit |
| three  | #86BBD8 | (palette defined, unused) |
| four   | #06969A | language modules |
| five   | #33658A | docker_context, package |
| bright | #e5e5e5 | text highlight |
| dark   | bright-black | text |