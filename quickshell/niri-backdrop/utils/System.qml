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

    readonly property string hostname: hostnameFile.text().trim()
}
