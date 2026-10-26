// runner.js
/// Impl for the runner provider

function query(provider, query) {
  if (query === "") {
    return [];
  }
  return [
    {
      identifier: "sh",
      text: "sh -c " + query,
      icon: "",
      provider: provider,
      active: true,
      hints: { monospace: true, autoHeight: true },
      actions: { default: "execute" },
    },
    {
      identifier: "systemd-run",
      text: "systemd-run --user -- " + query,
      icon: "",
      provider: provider,
      active: true,
      hints: { monospace: true, autoHeight: true },
      actions: { default: "systemd-run" },
    }
  ];
}

function activate(provider, entry, action, query) {
  let cmd = [];
  if (action === "execute") {
    cmd = ["sh", "-c", query];
  } else if (action === "systemd-run") {
    cmd = ["systemd-run", "--user", "--", "sh", "-c", query];
  } else {
    return null;
  }
  console.log("[Launcher][runner]", cmd);
  Quickshell.execDetached(cmd);
  return { close: true };
}
