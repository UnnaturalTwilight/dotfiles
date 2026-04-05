// Brightness.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int screenRaw: 0
    property int screenMax: 96000
    property alias screenValue: persist.screenValue

    property alias backlightSaved: persist.backlightSaved
    property alias kbdBacklightSaved: persist.kbdBacklightSaved

    // Valid values:
    //  specific value      Example: 500
    //  percentage value    Example: 50%
    //  specific delta      Example: 50- or +10
    //  percentage delta    Example: 50%- or +10%
    function setScreen(value: string) {
        // min-value is set to 4800 (5%)
        brightnessSetProc.exec(["brightnessctl", "set", value, "--min-value=4800"]);
        backlightSaved = false;
    }

    function dimScreen(force = false) {
        saveScreen(force);
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", "10"]);
    }

    function saveScreen(force = false) {
        if (force || !backlightSaved) {
            Quickshell.execDetached(["brightnessctl", "--save", "--class=backlight"]);
            backlightSaved = true;
        } else {
            // console.log("saveScreen was called with brightness already saved")
        }
    }

    function restoreScreen(force = false) {
        if (force || backlightSaved) {
            brightnessSetProc.exec(["brightnessctl", "--restore", "--class=backlight"]);
            backlightSaved = false;
        } else {
            // console.log("restoreScreen was called without brightness being saved")
        }
    }

    function keyboard(enabled: bool, force = false) {
        if (enabled && (force || kbdBacklightSaved)) {
            Quickshell.execDetached(["brightnessctl", "--restore", "--device", "chromeos::kbd_backlight"]);
            kbdBacklightSaved = false;
        } else if (!enabled && (force || !kbdBacklightSaved)) {
            Quickshell.execDetached(["brightnessctl", "--save", "--device", "chromeos::kbd_backlight", "set", "0"]);
            kbdBacklightSaved = true;
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

        property real screenValue: (root.screenMax > 0) ? (root.screenRaw / root.screenMax) : 0
    }

    IpcHandler {
        id: brightnessIPC
        target: "brightness"

        function refresh() {
            root.fetch();
        }
        function set(value: string) {
            root.setScreen(value);
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
                    root.screenRaw = parseInt(a[2]);
                    root.screenMax = parseInt(a[4]);
                } else {
                    console.error("brightnessctl output was empty");
                }
            }
        }
    }
}
