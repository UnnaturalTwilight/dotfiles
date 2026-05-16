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
        if (hr > 0) {
            comps.push(`${hr} hours`);
        }
        if (min > 0) {
            comps.push(`${min} mins`);
        }

        return comps.join(", ") || fallback;
    }

    readonly property int iconIdx: {
        if (state === UPowerDeviceState.Unknown) {
            return 12;
        } else if (state === UPowerDeviceState.Charging) {
            return 11;
        } else {
            return Math.round(10 - (value * 10));
        }
    }

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
        "battery/charging",
        "battery/unknown"
    ]

    readonly property list<string> fontIcons: ["󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺", "󰂎", "󰂄", "󰂑"]
}
