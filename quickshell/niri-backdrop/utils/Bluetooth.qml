// Bluetooth.qml
pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property bool devices: Bluetooth.devices;
    readonly property bool adapter: Bluetooth.defaultAdapter;

    readonly property string icon: defaultAdapter?.enabled ? "󰂯" : "󰂲";
}