// Clipboard.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string value: Quickshell.clipboardText

    function copy(text) {
        Quickshell.clipboardText = text;
        // Qt.callLater(() => Clipboard.refreshHistory());
    }

    // property alias history: historyModel.values

    // ScriptModel {
    //     id: historyModel
    // }

    // function refreshHistory() {
    //     cliphistProc.running = true;
    // }

    // Process {
    //     id: cliphistProc
        
    //     running: true
    //     command: ["cliphist", "list"]

    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             const entries = text.trim().split("\n").map(line => ({ id: line.split("\t")[0], value: line.split("\t")[1] }));
    //             historyModel.values = entries;
    //         }
    //     }
    // }

    // function copyById(id) {
    //     histDecodeProc.exec(["cliphist", "decode", id]);
    // }

    // Process {
    //     id: histDecodeProc

    //     running: false
    //     command: ["cliphist", "decode"]

    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             root.copy(text);
    //         }
    //     }
    // }

    // function wipeHistory() {
    //     Quickshell.execDetached(["cliphist", "wipe"]);
    // }
}
