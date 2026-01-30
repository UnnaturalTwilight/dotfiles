// Battery.qml
pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    readonly property real value: {
        return UPower.displayDevice.percentage;
    }

    readonly property UPowerDeviceState state: {
        return UPower.displayDevice.state;
    }

    readonly property string icon: {
        return state === UPowerDeviceState.Charging ? icons[11] :
            value < 0.05 ? icons[10] :
            value < 0.15 ? icons[9] :
            value < 0.25 ? icons[8] :
            value < 0.35 ? icons[7] :
            value < 0.45 ? icons[6] :
            value < 0.55 ? icons[5] :
            value < 0.65 ? icons[4] :
            value < 0.75 ? icons[3] :
            value < 0.85 ? icons[2] :
            value < 0.95 ? icons[1] :
            icons[0]
    }

    readonly property list<string> icons: ["󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺", "󰂎", "󰂄"]
}
