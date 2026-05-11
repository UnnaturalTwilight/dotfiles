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
    readonly property int iconIdx: {
        return state === UPowerDeviceState.Charging ? 11
            : value < 0.05 ? 10
            : value < 0.15 ? 9
            : value < 0.25 ? 8
            : value < 0.35 ? 7
            : value < 0.45 ? 6
            : value < 0.55 ? 5
            : value < 0.65 ? 4
            : value < 0.75 ? 3
            : value < 0.85 ? 2
            : value < 0.95 ? 1
            : 0;
    }
    // qmlformat on

    readonly property list<string> icons: [
        "battery/full",
        "battery/90",
        "battery/80",
        "battery/70",
        "battery/60",
        "battery/50",
        "battery/40",
        "battery/30",
        "battery/20",
        "battery/10",
        "battery/outline",
        "battery/charging"
    ]
    readonly property list<string> fontIcons: ["󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺", "󰂎", "󰂄"]
}
