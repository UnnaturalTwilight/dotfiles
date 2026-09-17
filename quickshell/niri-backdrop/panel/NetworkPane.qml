// NetworkPane.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: netPane
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

    ListView {
        id: bluetoothList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: netPane.margin
        spacing: netPane.margin
        implicitHeight: Math.min(contentHeight, 480)
        model: ScriptModel {
            values: Devices.bluetooth.sort(Devices.bluetoothDeviceSorting)
        }
        delegate: DeviceListEntry {}

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 250
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 250
                }
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
            }
        }
    }

    component DeviceListEntry: Rectangle {
        id: btDevice
        required property var modelData
        height: 50
        width: bluetoothList.width
        radius: netPane.radius
        color: deviceMouseArea.containsMouse ? Colours.highlight : Colours.shadow
        border.color: btDevice.working ? Colours.aurora4 : "transparent"
        border.width: 2

        property bool working: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

        SvgIcon {
            id: deviceIcon
            iconName: Devices.getIcon(btDevice.modelData.name, btDevice.modelData.icon || "bluetooth")
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: netPane.margin
            size: 32
            colour: btDevice.modelData.connected ? Colours.mana2 : Colours.gray
        }

        Text {
            text: btDevice.modelData.name
            color: btDevice.modelData.connected ? Colours.text : Colours.gray
            font.family: Fonts.mono
            font.pixelSize: 20
            padding: 8
            anchors.left: deviceIcon.right
            anchors.verticalCenter: parent.verticalCenter
            font.bold: btDevice.working ?? false
        }

        SvgIcon {
            id: deviceBatteryIcon
            iconName: Battery.icons[Math.round(10 - (btDevice.modelData.battery * 10))]
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: netPane.margin
            size: 32
            colour: btDevice.modelData.battery > 0.2 ? Colours.snow0 : Colours.aurora0
            visible: btDevice.modelData.batteryAvailable
        }

        MouseArea {
            id: deviceMouseArea
            anchors.fill: parent
            onClicked: btDevice.modelData.connected ? btDevice.modelData.disconnect() : btDevice.modelData.connect()
            hoverEnabled: true
        }
    }
}
