// Brightness.qml
pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int screenRaw: 0
    property int screenMax: 96000
    property real screenValue: (screenMax > 0) ? (screenRaw / screenMax) : 0

    onScreenValueChanged: {
        console.log("Brightness changed to " + root.screenValue);
    }

    property bool backlightSaved: false
    property bool kbdBacklightSaved: false

    // Valid values:
    //  specific value      Example: 500
    //  percentage value    Example: 50%
    //  specific delta      Example: 50- or +10
    //  percentage delta    Example: 50%- or +10%
    function setScreen(value: string) {
        // min-value is set to 4800 (5%)
        brightnessProc.exec(["brightnessctl", "-m", "set", value, "--min-value=4800"]);
        backlightSaved = false;
    }

    function dimScreen(force = false) {
        saveScreen(force);
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", "10"]);
    }

    function saveScreen(force = false) {
        if (force || !backlightSaved) {
            brightnessProc.exec(["brightnessctl", "-m", "--save", "--class=backlight"]);
            backlightSaved = true;
        } else {
            // console.log("saveScreen was called with brightness already saved")
        }
    }

    function restoreScreen(force = false) {
        if (force || backlightSaved) {
            brightnessProc.exec(["brightnessctl", "-m", "--restore", "--class=backlight"]);
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
        brightnessProc.exec(["brightnessctl", "-m", "info", "--class=backlight"]);
    }

    Process {
        id: brightnessProc

        running: true
        command: ["brightnessctl", "-m", "info", "--class=backlight"]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("brightnessctl output: " + text);
                const a = text.split(",");
                root.screenRaw = parseInt(a[2]);
                root.screenMax = parseInt(a[4]);
            }
        }
    }
}
