// Network.qml
pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property bool online: Networking.connectivity === NetworkConnectivity.Full
    readonly property bool airplaneMode: Networking.wifiEnabled === false || Networking.wifiHardwareEnabled === false

    readonly property var connectionIcon: {
        if (Networking.connectivity === NetworkConnectivity.Full) {
            if (devices?.values[0]?.connected) {
                if (devices.values[0].type === DeviceType.Wifi) {
                    return signalStrength > 0 ? "network/wifi_" + Math.ceil(signalStrength * 3) : "network/wifi_off";
                } else if (devices.values[0].type === DeviceType.Wired) {
                    return "network/ethernet";
                }
            }
            return "network/web";
        } else if (Networking.connectivity === (NetworkConnectivity.Portal || NetworkConnectivity.Limited)) {
            return "network/web";
        }
        return "network/web_off";
    }

    readonly property string connectionString: {
        if (Networking.connectivity === NetworkConnectivity.Full) {
            return networks.values.find(n => n.connected)?.name || "Online";
        }
        return "Offline";
    }

    readonly property real signalStrength: networks.values.find(n => n.connected)?.signalStrength ?? 0

    ScriptModel {
        id: devices
        values: [...Networking.devices.values].sort(root.deviceSorting)
    }

    ScriptModel {
        id: networks
        values: Networking.devices?.values.find(d => d.type === DeviceType.Wifi)?.networks.values ?? []
    }

    function deviceSorting(a, b) {
        // Connected > Wifi > Other
        let aScore = 0;
        let bScore = 0;
        if (a.connected)
            aScore += 2;
        if (a.type === DeviceType.Wifi)
            aScore += 1;
        if (b.connected)
            bScore += 2;
        if (b.type === DeviceType.Wifi)
            bScore += 1;
        return bScore - aScore;
    }

    function refresh() {
        if (Networking.canCheckConnectivity) {
            Networking.checkConnectivity();
        }
    }
}
