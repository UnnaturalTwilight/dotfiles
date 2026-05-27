// From: https://github.com/tpaau/dots/blob/main/private_dot_config/quickshell/services/niri/Niri.qml

// Since Quickshell doesn't have an API for Niri, only for I3 and Hyprland, I
// had to create my own.
//
// This implementation is *not* complete; some events are not handled, and only
// a handful of functions for Niri actions are implemented.
//
// Both `OverviewButtons` and `NiriWorkspaces` use this service. See those
// components for examples.
//
// Documentation based on https://yalter.github.io/niri/niri_ipc/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")

    // All the Niri workspaces.
    property list<NiriWorkspace> workspaces: []

    // Every monitor has at least one workspace, so we poll for outputs every
    // time workspaces change.
    onWorkspacesChanged: outputProc.running = true

    // The currently focused workspace.
    property NiriWorkspace focusedWorkspace: null

    // All the windows registered in Niri.
    property list<NiriWindow> windows: []

    // The currently focused window.
    property NiriWindow focusedWindow: null

    // Monitor outputs recognized by Niri.
    property list<NiriOutput> outputs: []

    // The output that contains the focused workspace.
    readonly property NiriOutput focusedOutput: outputs.find(o => o.name == focusedWorkspace.output) ?? null

    // Whether the overview mode is currently active. Setting this value does
    // nothing.
    property bool overviewOpened: false

    // Screenshots the current window. That one doesn't use the Quickshell
    // socket, sorry.
    function screenshotWindow() {
        Quickshell.execDetached(["niri", "msg", "action", "screenshot-window"]);
    }

    // The name of the current keyboard layout, or "" if unknown.
    readonly property string keyboardLayout: keyboardLayouts.length > keyboardLayoutIndex ? keyboardLayouts[keyboardLayoutIndex] : ""

    // XKB names of the configured keyboard layouts.
    property list<string> keyboardLayouts: []

    // Index of the currently active layout in `keyboardLayouts`.
    property int keyboardLayoutIndex: 0

    property bool configValid: true

    // Toggles the overview mode.
    function toggleOverview() {
        send({
            Action: {
                ToggleOverview: {}
            }
        });
    }

    // Kills all windows registered by Niri.
    function closeAllWindows() {
        for (const window of windows) {
            Quickshell.execDetached(["kill", window.pid.toString()]);
        }
    }

    // Quit niri
    function quitNiri(force = false) {
        send({
            Action: {
                Quit: {
                    skip_confirmation: force
                }
            }
        });
    }

    function sleepDisplay() {
        send({
            Action: {
                PowerOffMonitors: {}
            }
        });
    }

    // Activates the workspace with the given ID.
    function activateWorkspace(id: int) {
        send({
            Action: {
                FocusWorkspace: {
                    reference: {
                        Id: id
                    }
                }
            }
        });
    }

    function send(request) {
        requestSocket.write(JSON.stringify(request) + "\n");
    }

    function outputFromShellScreen(screen: ShellScreen): NiriOutput {
        return outputs.find(o => o.name == screen.name);
    }

    Component {
        id: workspaceComp
        NiriWorkspace {}
    }

    Component {
        id: windowComp
        NiriWindow {}
    }

    Component {
        id: layoutComp
        WindowLayout {}
    }

    Component {
        id: niriOutputMode
        OutputMode {}
    }

    Component {
        id: niriOutput
        NiriOutput {}
    }

    // Niri unfortunately does not provide output information in the event stream,
    // so I had to implement my own wrapper for `niri msg outputs`.
    Process {
        id: outputProc
        command: ["niri", "msg", "-j", "outputs"]
        running: true // Poll as soon as the service is loaded

        stdout: StdioCollector {
            onStreamFinished: {
                const parsedOutputs = JSON.parse(text);
                let outputs = [];
                for (const parsedOutput of Object.keys(parsedOutputs)) {
                    const output = parsedOutputs[`${parsedOutput}`];
                    let modes = [];
                    for (const parsedMode of output.modes) {
                        modes.push(niriOutputMode.createObject(root, {
                            width: parsedMode.width,
                            height: parsedMode.height,
                            refreshRate: parsedMode.refresh_rate,
                            isPreferred: parsedMode.is_preferred
                        }));
                    }
                    // console.log("NiriService: Output detected: " + output.name + " with mode: " + JSON.stringify(output.current_mode));
                    outputs.push(niriOutput.createObject(root, {
                        name: output.name,
                        make: output.make,
                        model: output.model,
                        serial: output.serial,
                        physicalWidth: output.physical_size[0],
                        physicalHeight: output.physical_size[1],
                        modes: modes,
                        currentMode: output.current_mode ?? -1,
                        isCustomMode: output.is_custom_mode,
                        vrrSupported: output.vrr_supported,
                        vrrEnabled: output.vrr_enabled
                    }));
                }
                root.outputs = outputs;
            }
        }
    }

    // Poll the outputs when `Quickshell.screens` changes.
    Connections {
        target: Quickshell
        function onScreensChanged() {
            outputProc.running = true;
        }
    }

    // This socket is for sending requests to Niri.
    Socket {
        id: requestSocket
        path: root.socketPath
        connected: true
    }

    // This timer is to force refreshing the data from niri as a pach for the ghost windows
    // Timer {
    //     interval: 10000
    //     running: true
    //     repeat: true
    //     onTriggered: {
    //         eventSocket.connected = false
    //         eventSocket.connected = true
    //     }
    // }

    // And this one is for receiving events from Niri.
    Socket {
        id: eventSocket
        path: root.socketPath
        connected: true

        onConnectionStateChanged: {
            write('"EventStream"\n'); // Ask Niri to stream the events.
            flush();
        }

        parser: SplitParser {
            function createWindow(data: var): NiriWindow {
                if (!data) {
                    console.warn("[Window] Data is not truthy!");
                }
                return windowComp.createObject(root, {
                    windowId: data.id,
                    title: data.title,
                    appId: data.app_id,
                    pid: data.pid,
                    workspaceId: data.workspace_id ?? -1,
                    isFocused: data.is_focused,
                    isFloating: data.is_floating,
                    isUrgent: data.is_urgent,
                    layout: createLayout(data.layout),
                    focusTimestamp: data.focus_timestamp != null ? data.focus_timestamp.secs + data.focus_timestamp.nanos / 1000000000.0 : -1.0
                });
            }

            function createLayout(data: var): WindowLayout {
                if (!data) {
                    console.warn("[Layout] Data is not truthy!");
                }
                return layoutComp.createObject(root, {
                    tileIndexInScrollingLayout: data.pos_in_scrolling_layout ? data.pos_in_scrolling_layout[0] : -1,
                    columnIndexInScrollingLayout: data.pos_in_scrolling_layout ? data.pos_in_scrolling_layout[1] : -1,
                    tileWidth: data.tile_size[0] ?? -1,
                    tileHeight: data.tile_size[1] ?? -1,
                    windowWidth: data.window_size[0] ?? -1,
                    windowHeight: data.window_size[1] ?? -1,
                    tilePosInWorkspaceViewX: data.tile_pos_in_workspace_view ? data.tile_pos_in_workspace_view[0] : -1,
                    tilePosInWorkspaceViewY: data.tile_pos_in_workspace_view ? data.tile_pos_in_workspace_view[1] : -1,
                    windowOffsetInTileX: data.window_offset_in_tile[0],
                    windowOffsetInTileY: data.window_offset_in_tile[1]
                });
            }

            function focusWindow(id: int) {
                if (id == -1) {
                    root.focusedWindow = null;
                    for (let win of root.windows) {
                        win.isFocused = false;
                    }
                    return;
                }
                if (root.focusedWindow)
                    root.focusedWindow.isFocused = false;
                for (let win of root.windows) {
                    if (win.windowId === id) {
                        win.isFocused = true;
                        root.focusedWindow = win;
                        return;
                    }
                }
            }

            onRead: line => {
                const event = JSON.parse(line);
                // console.log("NiriService: Event received: " + JSON.stringify(event));

                if (event.OverviewOpenedOrClosed) {
                    // {"OverviewOpenedOrClosed":{"is_open": BOOL }}
                    root.overviewOpened = event.OverviewOpenedOrClosed.is_open;
                } else if (event.WorkspacesChanged) {
                    // {"WorkspacesChanged":{"workspaces":[ { WORKSPACE DATA }, ... ]}}
                    // Contains full workspace config, overrides all workspaces.
                    let newWorkspaces = [];
                    // console.log("NiriService: WorkspacesChanged: " + JSON.stringify(event.WorkspacesChanged.workspaces));
                    for (const workspace of event.WorkspacesChanged.workspaces) {
                        const ws = workspaceComp.createObject(root, {
                            workspaceId: workspace.id,
                            idx: workspace.idx,
                            name: workspace.name,
                            output: workspace.output,
                            isUrgent: workspace.is_urgent,
                            isActive: workspace.is_active,
                            isFocused: workspace.is_focused,
                            activeWindowId: workspace.active_window_id != null ? workspace.active_window_id : -1
                        });
                        if (ws.isFocused) {
                            root.focusedWorkspace = ws;
                        }
                        newWorkspaces.push(ws);
                    }
                    newWorkspaces = newWorkspaces.sort((a, b) => a.idx - b.idx);
                    root.workspaces = newWorkspaces;
                } else if (event.WorkspaceActivated) {
                    // {"WorkspaceActivated":{"id": INT ,"focused": BOOL }}
                    // workspace with id is activated. Focused is true if it on the currently focused output.
                    const ws = event.WorkspaceActivated;
                    if (root.focusedWorkspace) {
                        root.focusedWorkspace.isFocused = false;
                    }
                    for (const workspace of root.workspaces) {
                        if (workspace.workspaceId === ws.id) {
                            workspace.isFocused = true;
                            root.focusedWorkspace = workspace;
                            return;
                        }
                    }
                    console.warn("NiriService: New focused workspace not found. This likely a bug in the IPC implementation.");
                } else if (event.WindowsChanged) {
                    // {"WindowsChanged":{"windows":[ { WINDOW DATA }, ... ]}}
                    // Contains full window config, overrides all windows.
                    let windows = [];
                    for (const win of event.WindowsChanged.windows) {
                        windows.push(createWindow(win));
                    }
                    root.windows = windows;
                    focusWindow(root.windows.find(w => w.isFocused)?.windowId ?? -1);
                } else if (event.WindowOpenedOrChanged) {
                    // {"WindowOpenedOrChanged":{"window":{ WINDOW DATA }}
                    // Contains single modified or new window, should be merged with existing windows.
                    const win = createWindow(event.WindowOpenedOrChanged.window);
                    const foundWindow = root.windows.find(w => w.windowId === win.windowId);
                    if (foundWindow) {
                        root.windows[root.windows.indexOf(foundWindow)] = win;
                        if (win.isFocused)
                            focusWindow(win.windowId);
                    } else {
                        if (win.isFocused)
                            focusWindow(win.windowId);
                        root.windows.push(win);
                    }
                } else if (event.WindowClosed) {
                    // {"WindowClosed":{"id": INT }}
                    // window with id is closed.
                    // console.log("NiriService: WindowClosed: " + event.WindowClosed.id);
                    root.windows = root.windows.filter(w => w.windowId !== event.WindowClosed.id);
                } else if (event.WindowFocusChanged) {
                    // {"WindowFocusChanged":{"id": INT }}
                    // window with id is focused. id is null if no window is focused
                    focusWindow(event.WindowFocusChanged.id == null ? -1 : event.WindowFocusChanged.id);
                } else if (event.WorkspaceActiveWindowChanged) {
                    // {"WorkspaceActiveWindowChanged":{"workspace_id": INT,"active_window_id": INT }}
                    // The active window in the workspace with workspace_id changed to active_window_id
                    const someEvent = event.WorkspaceActiveWindowChanged;
                    const workspace = root.workspaces.find(w => w.workspaceId == someEvent.workspace_id);
                    if (workspace) {
                        workspace.activeWindowId = someEvent.active_window_id != null ? someEvent.active_window_id : -1;
                    } else {
                        console.warn(`Workspace with id ${someEvent.workspace_id} not found. This is likely a bug in the IPC implementation.`);
                    }
                } else if (event.WindowFocusTimestampChanged) {
                    // {"WindowFocusTimestampChanged":{"id": INT,"focus_timestamp": { "secs": INT, "nanos": INT }}}
                    // The focus timestamp of the window with id changed to focus_timestamp
                    const someEvent = event.WindowFocusTimestampChanged;
                    const win = root.windows.find(w => w.windowId === someEvent.id);
                    if (win) {
                        win.focusTimestamp = someEvent.focus_timestamp != null ? someEvent.focus_timestamp.secs + someEvent.focus_timestamp.nanos / 1000000000.0 : -1;
                    } else {
                        console.warn(`Could not find window with id ${someEvent.id}. This is likely a bug in the IPC implementation.`);
                    }
                } else if (event.WindowUrgencyChanged) {
                    // {"WindowUrgencyChanged":{"id": INT,"urgent": BOOL }}
                    // The urgency of the window with id changed
                    const id = event.WindowUrgencyChanged.id;
                    const urgent = event.WindowUrgencyChanged.urgent;
                    for (let win of root.windows) {
                        if (win.windowId === id) {
                            win.isUrgent = urgent;
                            // console.log("NiriService: WindowUrgencyChanged: " + id + " urgent: " + urgent);
                            return;
                        }
                    }
                } else if (event.WorkspaceUrgencyChanged) {
                    // {"WorkspaceUrgencyChanged":{"id": INT,"urgent": BOOL }}
                    // The urgency of the workspace with id changed
                    const id = event.WorkspaceUrgencyChanged.id;
                    const urgent = event.WorkspaceUrgencyChanged.urgent;
                    for (let ws of root.workspaces) {
                        if (ws.workspaceId === id) {
                            ws.isUrgent = urgent;
                            // console.log("NiriService: WorkspaceUrgencyChanged: " + id + " urgent: " + urgent);
                            return;
                        }
                    }
                } else if (event.WindowLayoutsChanged) {
                    // {"WindowLayoutsChanged":{"changes":[ [id, layout], ... ]}}
                    // An array of window IDs and their new layouts
                    const changes = event.WindowLayoutsChanged.changes;
                    for (const change of changes) {
                        const win = root.windows.find(w => w.windowId == change[0]);
                        // console.log("NiriService: WindowLayoutsChanged: " + change[0] + " layout: " + JSON.stringify(change[1]));
                        if (win) {
                            win.layout = createLayout(change[1]);
                        }
                    }
                } else if (event.KeyboardLayoutsChanged) {
                    root.keyboardLayoutIndex = event.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
                    root.keyboardLayouts = event.KeyboardLayoutsChanged.keyboard_layouts.names;
                } else if (event.CastsChanged) {
                    // {"CastsChanged": { "casts": [ DATA ]}}
                    // Ignored for now
                    return;
                } else if (event.ScreenshotCaptured) {
                    // {"ScreenshotCaptured": { "path": PATH or null }}
                    // Ignored for now
                    return;
                } else if (event.Ok) {
                    // Confirmation response of eventstream
                    return;
                } else if (event.ConfigLoaded) {
                    root.configValid = !event.ConfigLoaded.failed;
                } else {
                    console.log("NiriService: Unhandled event received: " + JSON.stringify(event));
                }
            }
        }
    }
}
