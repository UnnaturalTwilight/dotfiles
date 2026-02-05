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

    // The currently focused workspace.
    property NiriWorkspace focusedWorkspace: null

    // All the windows registered in Niri.
    property list<NiriWindow> windows: []

    // The currently focused window.
    property NiriWindow focusedWindow: null

    property NiriWindow emptyWindow: NiriWindow {
        windowId: -1
        title: ""
        appId: ""
        pid: -1
        workspaceId: -1
        isFocused: false
        isFloating: false
        isUrgent: false
    }

    // Whether the overview mode is currently active. Setting this value does
    // nothing.
    property bool overviewOpened: false

    // The name of the current keyboard layout, or "" if unknown.
    readonly property string keyboardLayout: keyboardLayouts.length > keyboardLayoutIndex ? keyboardLayouts[keyboardLayoutIndex] : ""

    // XKB names of the configured keyboard layouts.
    property list<string> keyboardLayouts: []

    // Index of the currently active layout in `keyboardLayouts`.
    property int keyboardLayoutIndex: 0

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
    function quitNiri() {
        send({
            Action: {
                Quit: {}
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

    Component {
        id: workspaceComp
        NiriWorkspace {}
    }

    Component {
        id: windowComp
        NiriWindow {}
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
            onRead: line => {
                const event = JSON.parse(line);
                // console.log("NiriService: Event received: " + JSON.stringify(event));

                if (event.OverviewOpenedOrClosed) {
                    // {"OverviewOpenedOrClosed":{"is_open": BOOL }}
                    root.overviewOpened = event.OverviewOpenedOrClosed.is_open;
                    return;
                } else if (event.WorkspacesChanged) {
                    // {"WorkspacesChanged":{"workspaces":[ { WORKSPACE DATA }, ... ]}}
                    // Contains full workspace config, overrides all workspaces.
                    let newWorkspaces = [];
                    for (const workspace of event.WorkspacesChanged.workspaces) {
                        const ws = workspaceComp.createObject(root, {
                            workspaceId: workspace.id,
                            idx: workspace.idx,
                            name: workspace.name,
                            output: workspace.output,
                            isUrgent: workspace.is_urgent,
                            isActive: workspace.is_active,
                            isFocused: workspace.is_focused,
                            activeWindowID: workspace.active_window_id ? workspace.active_window_id : -1
                        });
                        if (ws.isFocused) {
                            root.focusedWorkspace = ws;
                        }
                        // console.log("\nNiriService: WorkspacesChanged: workspace " + ws.workspaceId);
                        for (const win of root.windows) {
                            // console.log("NiriService: WorkspacesChanged: window " + win.windowId + " on old workspace " + win.workspaceId);
                            if (win.workspaceId === ws.workspaceId) {
                                ws.windows.push(win);
                                // console.log("NiriService: WorkspacesChanged: added window " + win.windowId + " to workspace " + ws.workspaceId);
                            }
                        }
                        newWorkspaces.push(ws);
                    }
                    newWorkspaces = newWorkspaces.sort((a, b) => a.idx - b.idx);
                    root.workspaces = newWorkspaces;
                    // console.log("NiriService: WorkspacesChanged: now " + JSON.stringify([...root.workspaces]));
                    return;
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
                    return;
                } else if (event.WindowsChanged) {
                    // {"WindowsChanged":{"windows":[ { WINDOW DATA }, ... ]}}
                    // Contains full window config, overrides all windows.
                    for (let workspace of root.workspaces) {
                        workspace.windows = [];
                    }
                    const eventWindows = event.WindowsChanged.windows;
                    let windows = [];
                    for (const win of eventWindows) {
                        const winObj = windowComp.createObject(root, {
                            windowId: win.id,
                            title: win.title,
                            appId: win.app_id,
                            pid: win.pid,
                            workspaceId: win.workspace_id ?? -1,
                            isFocused: win.is_focused,
                            isFloating: win.is_floating,
                            isUrgent: win.is_urgent,
                            positionInWorkspace: win.layout?.pos_in_scrolling_layout ? win.layout.pos_in_scrolling_layout[0] : 0
                        });
                        if (winObj.isFocused) {
                            root.focusedWindow = winObj;
                        }
                        windows.push(winObj);
                        for (let workspace of root.workspaces) {
                            if (workspace.workspaceId === winObj.workspaceId) {
                                workspace.windows.push(winObj);
                                // console.log("NiriService: WindowsChanged: " + winObj.windowId + " on workspace " + winObj.workspaceId);
                                break;
                            }
                        }
                    }
                    root.windows = windows;
                    return;
                } else if (event.WindowOpenedOrChanged) {
                    // {"WindowOpenedOrChanged":{"window":{ WINDOW DATA }}
                    // Contains single modified or new window, should be merged with existing windows.
                    const win = event.WindowOpenedOrChanged.window;
                    const winObj = windowComp.createObject(root, {
                        windowId: win.id,
                        title: win.title,
                        appId: win.app_id,
                        pid: win.pid,
                        workspaceId: win.workspace_id ?? -1,
                        isFocused: win.is_focused,
                        isFloating: win.is_floating,
                        isUrgent: win.is_urgent,
                        positionInWorkspace: win.layout?.pos_in_scrolling_layout ? win.layout.pos_in_scrolling_layout[0] : 0
                    });
                    for (const window of root.windows) {
                        if (window.windowId === winObj.windowId) {
                            // console.log("NiriService: WindowUpdated: " + winObj.windowId + " on workspace " + winObj.workspaceId + " old workspace: " + window.workspaceId);
                            root.windows.splice(root.windows.indexOf(window), 1, winObj);
                            if (window.workspaceId !== winObj.workspaceId) {
                                root.workspaces.find(ws => ws.workspaceId === window.workspaceId)?.windows.splice(root.workspaces.find(ws => ws.workspaceId === window.workspaceId)?.windows.findIndex(w => w.windowId === winObj.windowId), 1);
                                root.workspaces.find(ws => ws.workspaceId === winObj.workspaceId)?.windows.push(winObj);
                            } else {
                                root.workspaces.find(ws => ws.workspaceId === winObj.workspaceId)?.windows.splice(root.workspaces.find(ws => ws.workspaceId === winObj.workspaceId)?.windows.findIndex(w => w.windowId === winObj.windowId), 1, winObj);
                            }
                            return;
                        }
                    }
                    root.windows.push(winObj);
                    for (let workspace of root.workspaces) {
                        if (workspace.workspaceId === winObj.workspaceId) {
                            workspace.windows.push(winObj);
                            // console.log("NiriService: WindowOpened: " + winObj.windowId + " on workspace " + winObj.workspaceId);
                            return;
                        }
                    }
                } else if (event.WindowClosed) {
                    // {"WindowClosed":{"id": INT }}
                    // window with id is closed.
                    const id = event.WindowClosed.id;
                    root.windows.splice(root.windows.findIndex(w => w.windowId === id), 1);
                    for (const ws of root.workspaces) {
                        for (const win of ws.windows) {
                            if (win.windowId === id) {
                                ws.windows.splice(ws.windows.indexOf(win), 1);
                                // console.log("NiriService: WindowClosed: " + id + " on workspace " + ws.workspaceId);
                                return;
                            }
                        }
                    }
                } else if (event.WindowFocusChanged) {
                    const id = event.WindowFocusChanged.id;
                    if (root.focusedWindow) {
                        root.focusedWindow.isFocused = false;
                    }
                    for (let win of root.windows) {
                        if (win.windowId === id) {
                            // console.log("NiriService: WindowFocusChanged: " + id);
                            win.isFocused = true;
                            root.focusedWindow = win;
                            return;
                        }
                    }
                } else if (event.WindowUrgencyChanged) {
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
                    const changes = event.WindowLayoutsChanged.changes;
                    for (const change of changes) {
                        const id = change[0];
                        const newPos = change[1]?.pos_in_scrolling_layout ? change[1].pos_in_scrolling_layout[0] : 0;
                        // console.log("NiriService: WindowLayoutsChanged: " + id + " newPos: " + newPos);
                        for (let win of root.windows) {
                            if (win.windowId === id) {
                                win.positionInWorkspace = newPos;
                                win.isFloating = newPos < 1;
                                break;
                            }
                        }
                    }
                } else if (event.KeyboardLayoutsChanged) {
                    root.keyboardLayoutIndex = event.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
                    root.keyboardLayouts = event.KeyboardLayoutsChanged.keyboard_layouts.names;
                } else if (event.Ok) {
                    // Confirmation response of eventstream
                    return;
                } else {
                    // console.log("NiriService: Unhandled event received: " + JSON.stringify(event));
                }
            }
        }
    }
}
