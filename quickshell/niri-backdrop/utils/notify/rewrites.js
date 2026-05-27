// rewrites.js

// These functions can be used to change the appearance and behavior of notifications as they come in.
// the notif argument should be the original notification object so that previous rewrites don't affect the logic of later rewrites.

function rewriteSummary(summary, notif) {
  if (notif.appName == "rewrite-test") {
    return "Rewritten summary";
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
  if (notif.appName == "niri") {
    // add niri's logo as the image
    return "file:///home/cal/.config/assets/Icons/niri_icon.svg";
  }
  return image;
}

function getDefaultAction(actions, notif) {
  if (actions.length == 0) {
    return null;
  }

  // If there's only one action use it
  if (actions.length == 1) {
    return actions[0];
  }

  // Notifications from `kitten notify` have an blank first action that is meant to be the default
  if (actions[0].text.trim() == "") {
    return actions[0];
  }

  // Discord has a "View" action
  if (notif.appName == "discord") {
    return actions.find(a => a.text == "View");
  }

  // catch all guesswork, firefox/zen/thunderbird/chome all have "Activate" and "Open" seems like a safe bet
  return actions.find(a => a.text == "Activate") || actions.find(a => a.text == "Open");
}
