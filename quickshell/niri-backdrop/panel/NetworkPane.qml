// NetworkPane.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services

Rectangle {
    id: notifications
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height

    color: Colours.blurPane
    border.color: Colours.power5
    border.width: 2
    radius: 12

    property int margin: 10

    Text {
        id: netText
        text: Network.connectionString + "\t" + Network.signalStrength
        color: Colours.text
        font.family: Fonts.sans
        font.pixelSize: 20
        padding: 8
    }

    Text {
        id: bluetoothText
        text: "\n----\nBluetooth:\n"
        color: Colours.text
        font.family: Fonts.sans
        font.pixelSize: 20
        padding: 8
        anchors.top: netText.bottom
    }

    ListView {
        id: bluetoothList
        anchors.top: bluetoothText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height - bluetoothText.height - netText.height - margin
        model: Bluetooth.devices
        delegate: DeviceListEntry {}
    }

    component DeviceListEntry: Text {
        required property var modelData
        text: modelData.name
        color: modelData.connected ? Colours.text : Colours.gray
        font.family: Fonts.sans
        font.pixelSize: 20
        leftPadding: 8
    }
}
