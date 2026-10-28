// menus.js
/// Impl for menu-type providers

// Power Management
function queryPower(provider, query) {
  const list = [
    {
      identifier: "suspend",
      text: "Sleep",
      subtext: "Lock and suspend the system",
      provider: provider,
      actions: {
        default: "suspend",
        buttons: {
          icon: { type: "icon", icon: "power/sleep", action: "suspend" }
        }
      },
    },
    {
      identifier: "lock",
      text: "Lock",
      subtext: "Quickshell Lockscreen",
      provider: provider,
      actions: {
        default: "lock",
        buttons: {
          icon: { type: "icon", icon: "power/lock", action: "lock" }
        }
      },
    },
    {
      identifier: "logout",
      text: "Logout",
      subtext: "Exit Niri",
      provider: provider,
      actions: {
        default: "logout",
        buttons: {
          icon: { type: "icon", icon: "power/logout", action: "logout" }
        }
      },
    },
    {
      identifier: "shutdown",
      text: "Shutdown",
      subtext: "Fully shutdown the system  ·  [Ctrl 󰌑] to ignore inhibitors",
      provider: provider,
      actions: {
        default: "poweroff",
        ctrl: "poweroff-force",
        buttons: {
          icon: { type: "icon", icon: "power/poweroff", action: "poweroff" }
        }
      },
    },
    {
      identifier: "reboot",
      text: "Reboot",
      subtext: "[Ctrl 󰌑] to boot into Windows  ·  [Alt 󰌑] to perform a soft reboot",
      provider: provider,
      actions: {
        default: "reboot",
        ctrl: "reboot-windows",
        shift: "reboot-bios",
        alt: "reboot-soft",
        buttons: {
          icon: { type: "icon", icon: "power/restart", action: "reboot" }
        }
      },
    },
    {
      identifier: "hibernate",
      text: "Hibernate",
      subtext: "Lock and hibernate the system",
      provider: provider,
      actions: {
        default: "hibernate",
        buttons: {
          icon: { type: "icon", icon: "power/hibernate", action: "hibernate" }
        }
      },
    },
  ];
  return list.filter((e) => {
    return e.text.toLowerCase().startsWith(query.toLowerCase()) || e.identifier?.startsWith(query.toLowerCase());
  });
}

function activatePower(provider, entry, action, query) {
  switch (action) {
    case "lock":
      Idle.lock();
      break;
    case "suspend":
      Idle.sleep();
      break;
    case "logout":
      Niri.quitNiri();
      break;
    case "poweroff":
      Quickshell.execDetached(["systemctl", "poweroff"]);
      break;
    case "poweroff-force":
      Quickshell.execDetached(["systemctl", "poweroff", "--check-inhibitors=no"]);
      break;
    case "reboot":
      Quickshell.execDetached(["systemctl", "reboot"]);
      break;
    case "reboot-soft":
      Quickshell.execDetached(["systemctl", "soft-reboot"]);
      break;
    case "reboot-windows":
      Quickshell.execDetached(["systemctl", "reboot", "--boot-loader-entry=auto-windows"]);
      break;
    case "reboot-bios":
      Quickshell.execDetached(["systemctl", "reboot", "--firmware-setup"]);
      break;
    case "hibernate":
      Idle.lock();
      Niri.sleepDisplay();
      Quickshell.execDetached(["systemctl", "hibernate"]);
      break;
    default:
      return null;
  }
  return { close: true };
}

// System
function querySystem(provider, query) {
  return [
    {
      identifier: "restart-otd",
      text: "Restart Open Tablet Driver",
      subtext: "systemctl --user restart opentabletdriver.service",
      icon: "/usr/share/pixmaps/otd.png",
      provider: provider,
    },
    {
      identifier: "restart-elephant",
      text: "Restart Elephant",
      subtext: "systemctl --user restart elephant.service",
      icon: "reload",
      provider: provider,
    },
    {
      identifier: "colour-picker",
      text: "Colour Picker",
      subtext: "hyperpicker",
      icon: "color-picker",
      provider: provider,
    },
  ];
}

function activateSystem(provider, entry, action, query) {
  const id = entry?.identifier;
  switch (id) {
    case "restart-otd":
      Quickshell.execDetached(["systemctl", "--user", "restart", "opentabletdriver.service"]);
      break;
    case "restart-elephant":
      Quickshell.execDetached(["systemctl", "--user", "restart", "elephant.service"]);
      break;
    case "colour-picker":
      Quickshell.execDetached(["sh", "-c", "sleep 0.5 && hyprpicker -a"]);
      break;
    default:
      return null;
  }
  return { close: true };
}

// Quickshell
function queryQuickshell(provider, query) {
  return [
    {
      identifier: "qs-reload",
      text: "Reload",
      subtext: "[Ctrl 󰌑] to hard reload  ·  [Alt 󰌑] to restart the service",
      icon: "reload",
      provider: provider,
      actions: { default: "reload", ctrl: "hardreload", alt: "restart" },
    },
    {
      identifier: "qs-toggle-debug",
      text: "Toggle Debug Mode",
      subtext: System.debugMode ? "Debug mode is currently enabled" : "Debug mode is currently disabled",
      icon: "debug",
      provider: provider,
      hints: { active: true },
      actions: {
        default: "toggle-debug",
        ctrl: "debugRendering",
        buttons: {
          icon: { type: "icon", icon: "symbols/bug", action: "toggle-debug" },
          row: [
            { type: "checkbox", text: "Active", checked: true, action: "toggle-active" },
            { type: "checkbox", text: "Working", checked: false , action: "toggle-loading" },
            { type: "checkbox", text: "Debug Info", checked: LauncherState.debugRendering, action: "debugRendering" }
          ]
        }
      },
    },
  ];
  // TODO: IPC submenu??
}

function activateQuickshell(provider, entry, action, query) {
  if (entry.identifier === "qs-toggle-debug") {
    // DOCS: update = entry; doesn't work so to preserve all the hints and actions without re-defining them this needs to be done
    var update = {hints: entry.hints, actions: entry.actions};
    switch (action) {
      case "toggle-debug":
        System.debugMode = !System.debugMode;
        update.subtext = System.debugMode ? "Debug mode is currently enabled" : "Debug mode is currently disabled";
        break;
      case "toggle-active":
        update.hints.active = !entry?.hints?.active ?? false;
        break;
      case "toggle-loading":
        LauncherState.working = !LauncherState.working;
        break;
      case "debugRendering":
        LauncherState.debugRendering = !LauncherState.debugRendering;
        break;
    }
    update.actions.buttons.row[0].checked = update?.hints?.active ?? true;
    update.actions.buttons.row[1].checked = LauncherState.working;
    update.actions.buttons.row[2].checked = LauncherState.debugRendering;
    return { close: false, update };
  }

  if (action === "reload" || action === "hardreload") {
    Quickshell.reload(action === "hardreload");
  } else if (action === "restart") {
    Quickshell.execDetached([
      "systemctl",
      "--user",
      "restart",
      "quickshell@niri-backdrop.service",
    ]);
  }
  return { close: true };
}
