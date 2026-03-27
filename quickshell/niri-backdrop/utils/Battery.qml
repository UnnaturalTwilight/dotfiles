// Battery.qml
pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property var displayDevice: UPower.displayDevice
    readonly property bool ready: UPower.displayDevice.ready
    readonly property var devices: UPower.devices

    readonly property real value: {
        return UPower.displayDevice.percentage ?? 0.0;
    }

    readonly property var state: {
        return UPower.displayDevice.state ?? UPowerDeviceState.Unknown;
    }

    readonly property string approxTime: {
        if (state === UPowerDeviceState.FullyCharged || value >= 0.999) {
            return qsTr("Fully charged");
        } else if (state === UPowerDeviceState.Discharging) {
            if (UPower.displayDevice.timeToEmpty > 0) {
                return qsTr("%1 remaining").arg(formatSeconds(UPower.displayDevice.timeToEmpty, "Discharging"));
            } else {
                return qsTr("Discharging");
            }
        } else if (state === UPowerDeviceState.Charging) {
            if (UPower.displayDevice.timeToFull > 0) {
                return qsTr("%1 until full").arg(formatSeconds(UPower.displayDevice.timeToFull, "Charging"));
            } else {
                return qsTr("Charging");
            }
        } else {
            return "Unknown";
        }
    }

    function formatSeconds(s: int, fallback: string): string {
        const hr = Math.floor(s / 3600);
        const min = Math.floor(s / 60) % 60;

        let comps = [];
        if (hr > 0)
            comps.push(`${hr} hours`);
        if (min > 0)
            comps.push(`${min} mins`);

        return comps.join(", ") || fallback;
    }

    // qmlformat off
    readonly property string icon: {
        return state === UPowerDeviceState.Charging ? icons[11]
            : value < 0.05 ? icons[10]
            : value < 0.15 ? icons[9]
            : value < 0.25 ? icons[8]
            : value < 0.35 ? icons[7]
            : value < 0.45 ? icons[6]
            : value < 0.55 ? icons[5]
            : value < 0.65 ? icons[4]
            : value < 0.75 ? icons[3]
            : value < 0.85 ? icons[2]
            : value < 0.95 ? icons[1]
            : icons[0];
    }
    // qmlformat on

    readonly property list<string> icons: ["󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺", "󰂎", "󰂄"]
}
