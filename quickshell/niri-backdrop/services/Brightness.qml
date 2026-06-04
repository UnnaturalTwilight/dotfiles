// Brightness.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property alias screenRaw: persist.screenRaw
    readonly property alias screenMax: persist.screenMax
    readonly property real screenValue: screenRaw / screenMax

    signal showBrightnessOsd

    // Valid values:
    //  specific value      Example: 500
    //  percentage value    Example: 50%
    //  specific delta      Example: 50- or +10
    //  percentage delta    Example: 50%- or +10%
    function setScreen(value: string, showOsd = false) {
        // min-value is set to 4800 (5%)
        brightnessSetProc.exec(["brightnessctl", "--quiet", "--class=backlight", "set", value, "--min-value=4800"]);
        persist.backlightSaved = false;
        if (showOsd) {
            showBrightnessOsd();
        }
    }

    function dimScreen(force = false) {
        saveScreen(force);
        Quickshell.execDetached(["brightnessctl", "--quiet", "--class=backlight", "set", "10"]);
    }

    function saveScreen(force = false) {
        if (force || !persist.backlightSaved) {
            Quickshell.execDetached(["brightnessctl", "--quiet", "--save", "--class=backlight"]);
            persist.backlightSaved = true;
        } else {
            // console.log("saveScreen was called with brightness already saved")
        }
    }

    function restoreScreen(force = false) {
        if (force || persist.backlightSaved) {
            brightnessSetProc.exec(["brightnessctl", "--quiet", "--restore", "--class=backlight"]);
            persist.backlightSaved = false;
        } else {
            // console.log("restoreScreen was called without brightness being saved")
        }
    }

    function fetch() {
        if (brightnessFetchProc.running) {
            return; // Avoid spawning multiple processes if one is already running
        }
        brightnessFetchProc.running = true;
    }

    PersistentProperties {
        id: persist
        reloadableId: "Brightness"

        property bool backlightSaved: false
        property bool kbdBacklightSaved: false
        property int screenRaw: 0
        property int screenMax: 96000
    }

    IpcHandler {
        id: brightnessIPC
        target: "brightness"

        function refresh() {
            root.fetch();
        }
        function set(value: string) {
            root.setScreen(value, true);
        }
    }

    Process {
        id: brightnessSetProc

        running: false
        onExited: {
            brightnessFetchProc.running = true;
        }
    }

    Process {
        id: brightnessFetchProc

        running: true
        command: ["brightnessctl", "-m", "info", "--class=backlight"]

        stdout: StdioCollector {
            onStreamFinished: {
                const a = text.split(",");
                if (a[2] != "") {
                    persist.screenRaw = parseInt(a[2]);
                    persist.screenMax = parseInt(a[4]);
                } else {
                    console.error("brightnessctl output was empty");
                }
            }
        }
    }

    // FileView to watch for external brightness changes (internal displays only)
    readonly property FileView brightnessWatcher: FileView {
        id: brightnessWatcher
        path: "/sys/class/backlight/intel_backlight/actual_brightness"
        watchChanges: path !== ""
        onFileChanged: {
            // When a file change is detected, actively refresh from system
            // to ensure we get the most up-to-date value
            Qt.callLater(() => {
                brightnessFetchProc.running = true;
            });
        }
    }

}
