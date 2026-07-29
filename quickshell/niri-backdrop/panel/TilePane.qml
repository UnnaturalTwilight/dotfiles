// TilePane.qml

import Quickshell
import QtQuick
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

    AudioTile {
        anchors {
            top: systray.bottom
            left: tilePane.left
            right: tilePane.right
            margins: tilePane.margin
        }
        implicitHeight: 80
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
        // border.color: batteryMouseArea.containsMouse ? Colours.aurora4 : "transparent" //Colours.power5
        // border.width: 2
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
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    spacing: tilePane.margin

                    SvgIcon {
                        iconName: "power/sleep_off"
                        colour: Colours.snow0
                        size: 20
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
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
                        size: 20
                        Layout.preferredWidth: size
                        Layout.preferredHeight: size
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
                    Layout.columnSpan: 2
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
