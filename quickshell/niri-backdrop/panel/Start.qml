// Start.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

import qs
import qs.utils

PanelWindow {
    id: startPanel
    required property var modelData
    screen: modelData
    visible: modelData.name === "eDP-1" && persist.onscreen

    IpcHandler {
        target: "start"

        function toggle(): void {
            persist.onscreen = !persist.onscreen;
        }
        function show(): void {
            persist.onscreen = true;
        }
        function hide(): void {
            persist.onscreen = false;
        }
        function shown(): bool {
            return persist.onscreen;
        }
    }

    PersistentProperties {
        id: persist
        reloadableId: "persistedStates"

        property bool onscreen: false
    }
    property int buttonSize: 60

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overlay-qt-start"
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: true
        left: false
        bottom: true
    }

    margins {
        top: 30
        right: 30
        left: 0
        bottom: 30
    }

    implicitWidth: startBox.implicitWidth
    implicitHeight: startBox.implicitHeight
    Rectangle {
        id: startBox
        anchors.fill: parent
        color: Qt.alpha(Colours.bgGray, 1.0)
        opacity: 1
        radius: 12
        implicitWidth: 420

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                height: 160
                radius: 20
                color: Qt.alpha(Colours.black, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "User Info Placeholder"
                    font.pixelSize: 24
                    color: Colours.white
                }
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignCenter

                Repeater {

                    model: [
                        {
                            "text": "",
                            "action": ["systemctl", "poweroff"]
                        },
                        {
                            "text": "",
                            "action": ["systemctl", "reboot"]
                        },
                        {
                            "text": "󰤄",
                            "action": ["systemctl", "suspend"]
                        },
                        {
                            "text": "",
                            "action": ["loginctl", "lock-session"]
                        },
                        {
                            "text": "",
                            "action": ["niri", "msg", "action", "quit", "--skip-confirmation"]
                        },
                    ]

                    delegate: DelayButton {
                        required property var modelData
                        text: modelData.text
                        font.pixelSize: 48
                        font.family: "JetBrainsMonoNFM"
                        delay: 1000
                        onActivated: {
                            Quickshell.execDetached(modelData.action);
                            persist.onscreen = false;
                        }
                        implicitHeight: buttonSize
                        implicitWidth: buttonSize
                        contentItem: Text {
                            anchors.centerIn: parent
                            text: parent.text
                            font: parent.font
                            color: hovered ? Colours.pinkish : Colours.kindaGray
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        background: Shape {
                            anchors.centerIn: parent
                            implicitWidth: parent.width
                            height: parent.height
                            preferredRendererType: Shape.CurveRenderer
                            ShapePath {
                                property int lineweight: 4
                                //p = 2 * [ a + b - r * ( 4 - π ) ]
                                property real perimeter: 2 * (2 * buttonSize - (buttonSize / 4) * (4 - Math.PI))
                                strokeWidth: lineweight
                                strokeColor: hovered ? Colours.pinkish : Colours.kindaGray
                                strokeStyle: ShapePath.DashLine
                                dashPattern: [progress * (perimeter / lineweight), (perimeter / lineweight) - (progress * (perimeter / lineweight))]
                                dashOffset: -(buttonSize / 4) / lineweight
                                startX: 0
                                startY: 0
                                PathRectangle {
                                    width: buttonSize
                                    height: buttonSize
                                    radius: buttonSize / 4
                                    bevel: false
                                }
                                capStyle: ShapePath.RoundCap
                                // fillColor: Qt.alpha(Colours.darkGray, 0.6)
                                fillColor: "transparent"
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: batteryTile
                Layout.fillWidth: true
                property int tileHeight: 80
                color: "transparent"
                implicitHeight: tileHeight

                Rectangle {
                    id: tileBox
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Qt.alpha(Colours.kindaGray, 0.5)
                    border.width: 3
                    radius: 12

                    RowLayout {
                        id: tileContentRow
                        anchors.fill: parent
                        width: parent.width
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            verticalAlignment: Text.AlignVCenter
                            text: Battery.icon
                            font.pixelSize: 56
                            font.family: "JetBrainsMonoNFM"
                            color: Colours.kindaGray
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillWidth: true

                            Text {
                                text: Battery.approxTime
                                font.pixelSize: 16
                                font.family: "JetBrainsMonoNFM"
                                color: Colours.white
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Rectangle {
                                    // Stretches to fill all left-over space
                                    Layout.fillWidth: true

                                    implicitHeight: 12
                                    implicitWidth: 60
                                    radius: 20
                                    color: Colours.darkGray

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }

                                        implicitWidth: parent.width * Battery.value
                                        radius: parent.radius
                                        color: Colours.pinkish
                                    }
                                }
                                Text {
                                    text: (Battery.value * 100).toFixed(0) + "%"
                                    Layout.minimumWidth: 40
                                    font.pixelSize: 16
                                    font.family: "JetBrainsMonoNFM"
                                    color: Colours.white
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: audioTile
                Layout.fillWidth: true
                property int tileHeight: 80
                color: "transparent"
                implicitHeight: tileHeight

                Rectangle {
                    id: audioTileBox
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Qt.alpha(Colours.kindaGray, 0.5)
                    border.width: 3
                    radius: 12

                    RowLayout {
                        id: audioTileContentRow
                        anchors.fill: parent
                        width: parent.width
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            verticalAlignment: Text.AlignVCenter
                            text: Audio.icon
                            font.pixelSize: 56
                            font.family: "JetBrainsMonoNFM"
                            color: Colours.kindaGray
                        }

                        ColumnLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillWidth: true

                            Text {
                                text: Audio.description
                                font.pixelSize: 16
                                font.family: "JetBrainsMonoNFM"
                                color: Colours.white
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Rectangle {
                                    // Stretches to fill all left-over space
                                    Layout.fillWidth: true
                                    implicitHeight: 12
                                    implicitWidth: 60
                                    radius: 20
                                    color: Colours.darkGray

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }

                                        implicitWidth: parent.width * Audio.volume
                                        radius: parent.radius
                                        color: Colours.pinkish
                                        opacity: Audio.muted ? 0.5 : 1.0
                                    }
                                }
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    Layout.minimumWidth: 40
                                    text: (Audio.volume * 100).toFixed(0) + "%"
                                    font.pixelSize: 16
                                    font.family: "JetBrainsMonoNFM"
                                    color: Colours.white
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                radius: 20
                color: Qt.alpha(Colours.black, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "Placeholder"
                    font.pixelSize: 24
                    color: Colours.white
                }
            }
        }
    }
}
