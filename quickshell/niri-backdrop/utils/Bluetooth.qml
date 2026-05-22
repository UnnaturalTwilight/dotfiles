// Bluetooth.qml
pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    property alias devices: devicesModel.values

    ScriptModel {
        id: devicesModel
        values: {
            // console.log("Indexing Bluetooth devices...");
            // Bluetooth.devices.values.forEach(d => console.log(`Device: ${d.name}, Address: ${d.address}`, `State: ${BluetoothDeviceState.toString(d.state)}`));
            return [...Bluetooth.devices.values].sort(root.deviceSorting);
        }
    }
    readonly property string icon: adapter?.enabled ? "󰂯" : "󰂲";

    function batteryLevelByMAC(mac) {
        const device = devicesModel.values.find(d => d.address === mac);
        if (device?.batteryAvailable) {
            return device.battery;
        }
        return null;
    }

    function deviceSorting(a, b) {
        // Connected > Paired > Other
        let aScore = 0;
        let bScore = 0;
        if (a.connected) aScore += 2;
        if (a.paired) aScore += 1;
        if (b.connected) bScore += 2;
        if (b.paired) bScore += 1;
        return bScore - aScore;
    }
}
