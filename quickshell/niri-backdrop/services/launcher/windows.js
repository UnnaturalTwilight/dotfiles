// windows.js
/// Impl for the windows provider

function query(provider, query) {
  const list = [];

  for (const i in Niri.windows) {
    const window = Niri.windows[i];
    list.push({
      identifier: "niri-window-" + window.windowId,
      provider: "windows",
      text: window.title ?? "aaa",
      subtext: window.appId ?? "",
      icon: getAppIcon(window.appId),
      type: "window",
      hints: {
        workspaceId: window.workspaceId,
        windowId: window.windowId,
        appId: window.appId,
        pid: window.pid,
        focusTime: window.focusTimestamp,
      },
      actions: {
        default: "focus",
        buttons: {
          column: [{ action: "close", type: "icon", icon: "actions/close", destructive: true, text: "close" }]
        }
      },
    });
  }

  // Sort by focus time, with the most recently focused window first
  list.sort((a, b) => b.hints.focusTime - a.hints.focusTime);
  // Move the current window to the end
  list.push(list.shift());

  for (const i in Niri.workspaces) {
    const workspace = Niri.workspaces[i];
    // Skip empty workspaces
    if (workspace.activeWindowId === -1) { continue; }

    const activeWindow = Niri.windows.find((w) => w.windowId === workspace.activeWindowId);

    list.push({
      identifier: "niri-workspace-" + workspace.workspaceId,
      provider: "windows",
      text: workspace.name || "Workspace " + workspace.idx + " (" + workspace.output + ")",
      subtext: activeWindow?.title ?? "",
      icon: "cs-windows",
      type: "workspace",
      hints: {
        workspaceId: workspace.workspaceId,
      },
      actions: { default: "focus" },
    });
  }

  return list.filter((e) => {
    const match = e.text.toLowerCase().startsWith(query.toLowerCase()) || e.subtext.toLowerCase().startsWith(query.toLowerCase());
    return match;
  });
}

function activate(provider, entry, action, query) {
  if (action === "focus") {
    if (entry.hints?.windowId) {
      Niri.focusWindow(entry.hints.windowId);
      return { close: true }
    } else if (entry.hints?.workspaceId) {
      Niri.focusWorkspace(entry.hints.workspaceId);
      return { close: true }
    }
  } else if (action === "close") {
    if (entry.hints?.windowId) {
      Niri.closeWindow(entry.hints.windowId);
      return { close: false, remove: true }
    }
  } else if (action === "fullscreen") {
    if (entry.hints?.windowId) {
      Niri.fullscreenWindow(entry.hints.windowId);
      return { close: false }
    }
  }
  return null;
}

function getAppIcon(appId) {
  switch (appId) {
    case "zen":
      return "zen-browser";
    case "dev.zed.Zed":
      return "zed";
  }
  return appId ?? "";
}
