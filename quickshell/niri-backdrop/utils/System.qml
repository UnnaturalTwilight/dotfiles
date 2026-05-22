// System.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property alias hostname: persist.hostname
    readonly property string username: Quickshell.env("USER")

    PersistentProperties {
        id: persist
        reloadableId: "System"

        property string hostname: hostnameFile.text().trim()
    }

    FileView {
        id: hostnameFile
        path: Qt.resolvedUrl("/etc/hostname")
        blockLoading: false
    }

    readonly property ShellScreen primaryScreen: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === "eDP-1") {
                return Quickshell.screens[i];
            }
        }
        // in case eDP-1 is not found, just return the first screen
        console.log("eDP-1 not found, defaulting to first screen");
        return Quickshell.screens[0];
    }

    IpcHandler {
        id: systemIpc
        target: "sys"

        function reload() {
            Quickshell.reload(false);
        }

        function hardReload() {
            Quickshell.reload(true);
        }
    }
}
