// Devices.qml
pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: devices

    readonly property var bluetooth: Bluetooth.defaultAdapter.devices.values

    function getIcon(name, type = "unknown") {
        switch (name) {
            case "HESH 540 ANC":
                return "devices/headphones";
            case "Hearing Aids":
            case "Sesh ANC Active":
                return "devices/earbuds";
        }
        switch (type) {
            case "headphones":
            case "audio-headset":
                return "devices/headphones";
            case "earbuds":
                return "devices/earbuds";
            case "keyboard":
            case "input-keyboard":
                return "devices/keyboard";
            case "phone":
                return "devices/phone";
            case "bluetooth":
                return "network/bluetooth";
            default:
                return "unknown"; // Last Resort
        }
    }

    function batteryLevelByMAC(mac) {
        const device = Bluetooth.devices.values.find(d => d.address === mac);
        if (device?.batteryAvailable) {
            return device.battery;
        }
        return null;
    }

    function bluetoothDeviceSorting(a, b) {
        // Connected > Paired > Other
        let aScore = 0, bScore = 0;
        if (a.connected) aScore += 10;
        if (b.connected) bScore += 10;
        if (a.paired) aScore += 3;
        if (b.paired) bScore += 3;
        if (a.deviceName) aScore += 1;
        if (b.deviceName) bScore += 1;
        if (aScore === bScore) return a.name.localeCompare(b.name);
        return bScore - aScore;
    }
}
