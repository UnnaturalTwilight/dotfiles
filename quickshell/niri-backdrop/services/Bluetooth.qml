// Bluetooth.qml
pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property alias devices: devicesModel.values

    ScriptModel {
        id: devicesModel
        values: {
            // console.log("Indexing Bluetooth devices...");
            // Bluetooth.devices.values.forEach(d => console.log(`Device: ${d.name}, Address: ${d.address}`, `State: ${BluetoothDeviceState.toString(d.state)}`));
            return [...Bluetooth.devices.values].map(d => ({
                name: d.name,
                address: d.address,
                battery: d.batteryAvailable ? d.battery : null,
                icon: d.icon,
                connected: d.connected,
                paired: d.paired,
                trusted: d.trusted,
            })).sort(root.deviceSorting);
        }
    }

    function batteryLevelByMAC(mac) {
        const device = Bluetooth.devices.values.find(d => d.address === mac);
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
