// TilePane.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config
import qs.services
import qs.panel.systray
import qs.widgets

Rectangle {
    id: tilePane

    property int margin: 10
    implicitHeight: 320

    color: Qt.alpha(Colours.power5, 0.6)
    border.color: Colours.power5
    border.width: 2

    SysTray {
        id: systray
        // TODO: Rewrite the systray
        menuWidth: 400
        anchors {
            left: tilePane.left
            right: tilePane.right
            top: tilePane.top
            margins: tilePane.margin
        }
    }

    Rectangle {
        id: audioTileBox
        anchors {
            left: tilePane.left
            right: tilePane.right
            bottom: batteryTileBox.top
            // margins: tilePane.margin
            rightMargin: 85
        }
        implicitHeight: 90
        color: audioMouseArea.containsMouse ? Colours.highlight : "transparent"
        radius: tilePane.radius / 2

        MouseArea {
            id: audioMouseArea
            anchors.fill: parent

            hoverEnabled: true

            Button {
                id: audioIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                implicitWidth: 70
                implicitHeight: 70

                hoverEnabled: true
                onClicked: Audio.toggleMute()

                contentItem: SvgIcon {
                    iconName: Audio.icon
                    scale: 1.0 * (Audio.extraProps.iconDisplaySize / 80.0)
                    colour: audioIcon.hovered ? Colours.power1 : Colours.gray
                    opacity: Audio.muted ? 0.5 : 1.0
                    anchors.centerIn: parent
                }
                background: null
            }

            GridLayout {
                id: audioInfoGrid
                anchors {
                    left: parent.left
                    leftMargin: 70
                    right: parent.right
                    bottom: parent.bottom
                    margins: tilePane.margin * 1.5
                }
                rows: 2

                Dropdown {
                    id: dropdown
                    Layout.row: 0
                    Layout.fillWidth: true
                    // This filters out sinks with empty descriptions, In my case this is just a 'sink-input' for mpd
                    // If legit sinks have empty descriptions this will cause them to not show up in the dropdown
                    // Decriptions can be overridden in wireplumber config anyways
                    model: Audio.ready ? Audio.sinks?.map(s => ({
                                value: s.name,
                                text: s.description,
                                icon: s.name.startsWith("bluez_output") ? "network/bluetooth" : null
                            })).filter(m => m.text != "") : [Audio.description]
                    currentValue: Audio.name

                    onActivated: {
                        const sink = Audio.sinks.find(s => s.name === dropdown.currentValue);
                        if (sink) {
                            Audio.setDefaultSink(sink);
                        } else {
                            console.warn("Selected audio sink not found:", dropdown.currentValue);
                        }
                    }

                    background: null
                }

                RowLayout {
                    Layout.row: 0
                    Layout.column: 1
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight

                    SvgIcon {
                        iconName: Audio.extraProps.batteryIcon ?? "battery/unknown"
                        colour: Colours.snow0
                        size: 40
                        scale: 0.5
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
                        Layout.margins: -15
                        Layout.alignment: Qt.AlignRight
                        visible: Audio.extraProps.batteryIcon
                    }

                    SvgIcon {
                        iconName: "network/bluetooth"
                        colour: Colours.snow0
                        size: 40
                        scale: 0.5
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
                        Layout.margins: -15
                        Layout.alignment: Qt.AlignRight
                        visible: Audio.extraProps.bluetooth
                    }
                }

                Slider {
                    id: volumeControl
                    value: Audio.volume
                    stepSize: 0.02
                    wheelEnabled: true

                    Layout.row: 1
                    Layout.column: 0
                    Layout.fillWidth: true

                    background: PercentBar {
                        id: volumeBar
                        Layout.row: 1
                        Layout.fillWidth: true
                        implicitHeight: 12
                        value: volumeControl.visualPosition
                        active: !Audio.muted
                    }
                    handle: null

                    onMoved: {
                        Audio.setVolume(volumeControl.position);
                    }
                }

                Text {
                    Layout.row: 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignRight
                    text: (Audio.muted ? "" : Math.round(Audio.volume * 100) + "%").padStart(5, " ")
                    font.pixelSize: 16
                    font.family: Fonts.mono
                    color: Colours.text

                    SvgIcon {
                        id: volumeMuteIcon
                        anchors.right: parent.right
                        anchors.rightMargin: -15
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "audio/volume_mute"
                        colour: Colours.snow0
                        size: 60
                        scale: 0.5
                        visible: Audio.muted
                    }
                }
            }
        }
    }

    Rectangle {
        id: batteryTileBox
        anchors {
            left: tilePane.left
            right: tilePane.right
            bottom: tilePane.bottom
            // margins: tilePane.margin
        }
        implicitHeight: 90
        color: batteryMouseArea.containsMouse ? Colours.highlight : "transparent"
        radius: tilePane.radius / 2
        bottomLeftRadius: tilePane.radius
        bottomRightRadius: tilePane.radius

        MouseArea {
            id: batteryMouseArea
            anchors.fill: parent

            hoverEnabled: true
            acceptedButtons: Qt.MiddleButton
            onClicked: () => {
                Idle.enabled = !Idle.enabled;
            }

            SvgIcon {
                id: batteryIcon
                iconName: Battery.icons[Battery.iconIdx]
                size: 140
                scale: 0.5
                colour: Colours.gray

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: -(size * scale) / 2
                }
            }

            GridLayout {
                id: batteryInfoGrid
                anchors {
                    left: parent.left
                    leftMargin: 70
                    right: parent.right
                    bottom: parent.bottom
                    margins: tilePane.margin * 1.5
                }
                rows: 2

                Text {
                    Layout.row: 0
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    text: Battery.approxTime
                    font.pixelSize: 16
                    font.family: Fonts.mono
                    color: Colours.snow2
                }

                RowLayout {
                    Layout.row: 0
                    Layout.column: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    spacing: tilePane.margin

                    SvgIcon {
                        iconName: "power/sleep_off"
                        colour: Colours.snow0
                        size: 40
                        scale: 0.5
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
                        Layout.margins: -10
                        Layout.alignment: Qt.AlignRight
                        visible: !Idle.enabled
                    }

                    SvgIcon {
                        iconName: {
                            if (Battery.powerProfile === "Performance") {
                                return "power/performance-mode";
                            } else if (Battery.powerProfile === "PowerSaver") {
                                return "power/power-efficiency-mode";
                            }
                            return "unknown";
                        }
                        colour: Colours.snow0
                        size: 40
                        scale: 0.5
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
                        Layout.margins: -10
                        Layout.alignment: Qt.AlignRight
                        visible: Battery.powerProfile !== "Balanced"
                    }
                }

                PercentBar {
                    Layout.row: 1
                    Layout.column: 0
                    Layout.fillWidth: true
                    implicitHeight: 12
                    value: Battery.value
                }

                Text {
                    id: labelText
                    Layout.row: 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignRight
                    text: (Math.round(Battery.value * 100) + "%").padStart(5, " ")
                    font.pixelSize: 16
                    font.family: Fonts.mono
                    color: Colours.text
                }

                Text {
                    id: wattsLabel
                    Layout.row: 1
                    Layout.column: 2
                    Layout.alignment: Qt.AlignRight
                    text: Battery.watts.toFixed(2) + "W"
                    font.pixelSize: 16
                    font.family: Fonts.mono
                    color: Colours.text
                    Layout.preferredWidth: 80
                    horizontalAlignment: Qt.AlignRight
                }
            }
        }
    }
}
