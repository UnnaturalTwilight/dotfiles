// rewrites.js

function rewriteNotif(root, notif) {
  root.appName = notif.appName;
  root.appIcon = rewriteAppIcon(notif.appIcon, notif);
  root.summary = rewriteSummary(notif.summary, notif);
  root.body = rewriteBody(notif.body, notif);
  root.image = rewriteImage(notif.image, notif);
  root.urgency = notif.urgency;
  root.temporary = rewriteTemporary(notif.transient, notif);
  root.desktopEntry = notif.desktopEntry;
  root.hints = notif.hints;
  root.resident = notif.resident;
  root.actions = rewriteActions(notif.actions, notif);
  root.hasActionIcons = notif.hasActionIcons;
  root.hasInlineReply = notif.hasInlineReply;
  if (notif.hasInlineReply) {
    // Use the kde hint if it exists
    if (notif.hints?.["x-kde-reply-placeholder-text"] !== undefined) {
      root.inlineReplyPlaceholder = notif.hints["x-kde-reply-placeholder-text"];
    } else {
      root.inlineReplyPlaceholder = notif.inlineReplyPlaceholder;
    }
  }
}

// These functions can be used to change the appearance and behavior of notifications as they come in.
// the notif argument should be the original notification object so that previous rewrites don't affect the logic of later rewrites.

function rewriteSummary(summary, notif) {
  if (notif.appName == "rewrite-test") {
    return "Rewritten summary";
  }
  if (notif.desktopEntry == "org.mozilla.Thunderbird" && summary.trim() == "Thunderbird") {
    // remove the redundant "Thunderbird" summary on some Thunderbird notifications
    return "";
  }
  return summary;
}

function rewriteBody(body, notif) {
  if (notif.appName == "rewrite-test") {
    return "Rewritten body";
  }
  return body;
}

function rewriteImage(image, notif) {
  if (notif.appIcon.startsWith("file://") && notif.appName == "niri") {
    return notif.appIcon;
  }
  return image;
}

function rewriteAppIcon(appIcon, notif) {
  // rewrite app icon based on app name
  switch (notif.appName) {
    case "niri":
      return "file://" + Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/niri_icon.svg";
  }

  let resolvedIcon = Quickshell.iconPath(appIcon, true);
  if (appIcon.startsWith("file://")) {
    resolvedIcon = appIcon;
  } else if (notif.desktopEntry && !resolvedIcon) {
    // Thunderbird doesn't always set an app icon so this catches that case
    resolvedIcon = Quickshell.iconPath(notif.desktopEntry, true);
  }
  return resolvedIcon;
}

function rewriteTemporary(transient, notif) {
  switch (notif.appName) {
    case "udiskie":
    case "calibre":
    case "thunar":
      return true;
  }

  return transient;
}

function rewriteActions(actions, notif) {
  let rewrittenActions = actions.map(a => ({
    identifier: a.identifier,
    text: a.text,
    default: a.identifier == "default",
    display: a.identifier != "default" || a.text.trim().length > 0,
    invoke: () => a.invoke()
  }));

  if (notif.appName == "rewrite-test") {
    rewrittenActions = [
      { text: "Icon", identifier: "help", default: false, display: true, invoke: () => console.log("Icon Action clicked") },
      { text: "Dismiss", default: false, display: true, invoke: () => { console.log("Dismiss Action clicked"); notif?.dismiss(); } },
      { text: "Default", default: true, display: true, invoke: () => console.log("Default Action clicked") },
    ];
  }

  if (notif.desktopEntry == "org.mozilla.Thunderbird" && actions.length !== 0) {
    // Thunderbird needs special handling due to how I run it in the background
    let activateIdx = actions.findIndex(a => a.text == "Activate");
    if (activateIdx != -1) {
      rewrittenActions[activateIdx].invoke = () => {
        openThunderbird(notif);
        notif.actions[activateIdx].invoke();
      };
      rewrittenActions[activateIdx].default = true;
    }
  }

  return rewrittenActions;
}

function openThunderbird(notif) {
  // this is nessary due to how I run thunderbird in the background
  // const cmd = "$HOME/.config/scripts/niri_spawnjump.py $HOME/Monolith/birdmanager/stop-headless-and-launch.sh org.mozilla.Thunderbird";
  // Quickshell.execDetached(["sh", "-c", cmd]);
  Quickshell.execDetached(["systemctl", "--user", "start", "thunderbird.service"]);
}
