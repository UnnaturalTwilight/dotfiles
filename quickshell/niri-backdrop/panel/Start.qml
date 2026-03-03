// Start.qml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

import qs
import qs.utils
import qs.panel

PanelWindow {
    id: startPanel
    // required property ShellScreen modelData
    screen: Quickshell.screens.find(s => s.name === "eDP-1")
    visible: persist.onscreen

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

            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 0
                Layout.fillWidth: true

                Image {
                    Layout.rowSpan: 5
                    Layout.column: 0
                    Layout.maximumWidth: 150
                    Layout.maximumHeight: 150
                    source: Quickshell.env("XDG_CONFIG_HOME") + "/profilepic.png"
                    sourceSize.width: 1250
                    sourceSize.height: 1250
                    fillMode: Image.PreserveAspectCrop
                }

                Text {
                    Layout.column: 1
                    Layout.row: 1
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: Quickshell.env("USER") + "@" + System.hostname
                    font.pixelSize: 20
                    font.family: "JetBrainsMonoNFM"
                    color: Colours.kindaGray
                }

                Text {
                    Layout.column: 1
                    Layout.row: 2
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: "Network: WIP"
                    font.pixelSize: 20
                    font.family: "JetBrainsMonoNFM"
                    color: Colours.kindaGray
                }

                Text {
                    Layout.column: 1
                    Layout.row: 3
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: startPanel.screen?.name
                    font.pixelSize: 20
                    font.family: "JetBrainsMonoNFM"
                    color: Colours.kindaGray
                }

                // SysTray {
                //     id: systray
                //     Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                //     Layout.preferredHeight: 40
                //     Layout.fillWidth: true
                //     Layout.column: 1
                //     Layout.row: 3
                //     Layout.margins: 5
                //     Layout.bottomMargin: 10
                // }
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

            InfoTile {
                id: batteryTile
                vSize: 80
                icon: Text {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    text: Battery.icon
                    font.pixelSize: 56
                    font.family: "JetBrainsMonoNFM"
                    color: Colours.kindaGray
                }
                info: GridLayout {
                    columns: 2
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Text {
                        Layout.row: 0
                        Layout.column: 0
                        text: Battery.approxTime
                        font.pixelSize: 16
                        font.family: "JetBrainsMonoNFM"
                        color: Colours.white
                    }

                    PercentBar {
                        Layout.row: 1
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        value: Battery.value
                    }
                }
            }

            AudioTile {}

            SysTray {
                id: systray
                Layout.preferredHeight: 50
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 20
                color: Qt.alpha(Colours.black, 0.2)

                Text {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "Placeholder" + "\n"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 24
                    color: Colours.white
                }
            }
        }
    }
}
