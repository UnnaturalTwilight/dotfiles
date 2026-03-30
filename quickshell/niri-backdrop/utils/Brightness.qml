// Brightness.qml
pragma Singleton

import Quickshell

Singleton {
    id: root

    // Valid values:
    //  specific value      Example: 500
    //  percentage value    Example: 50%
    //  specific delta      Example: 50- or +10
    //  percentage delta    Example: 50%- or +10%
    function setBrightness(value: string) {
        // min-value is set to 4800 (5%)
        Quickshell.execDetached(["brightnessctl", "--save", "set", value, "--min-value=4800"]);
    }

    function dimScreen() {
        Quickshell.execDetached(["brightnessctl", "--save", "--class=backlight", "set", "10"]);
    }

    function restoreBrightness() {
        Quickshell.execDetached(["brightnessctl", "--restore", "--class=backlight"]);
    }

    function keyboardBacklight(enabled: bool) {
        if (enabled) {
            Quickshell.execDetached(["brightnessctl", "--restore", "--device", "chromeos::kbd_backlight"]);
        } else {
            Quickshell.execDetached(["brightnessctl", "--save", "--device", "chromeos::kbd_backlight", "set", "0"]);
        }
    }
}
