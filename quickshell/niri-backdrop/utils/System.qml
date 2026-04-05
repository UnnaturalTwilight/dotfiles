// System.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    reloadableId: "System"

    FileView {
        id: hostnameFile
        path: Qt.resolvedUrl("/etc/hostname")
        blockLoading: true
    }

    property alias hostname: persist.hostname

    PersistentProperties {
        id: persist
        reloadableId: "System"

        readonly property string hostname: hostnameFile.text().trim()
    }

    readonly property ShellScreen primaryScreen: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === "eDP-1") {
                return Quickshell.screens[i];
            }
        }
        // in case eDP-1 is not found, just return the first screen
        return Quickshell.screens[0];
    }

    // suppress popups on reload
    // property bool suppressOSD: true

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
