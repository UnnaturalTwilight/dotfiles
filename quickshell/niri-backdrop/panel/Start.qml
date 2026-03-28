// Start.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.panel

PanelWindow {
    id: startPanel
    // required property ShellScreen modelData
    screen: System.primaryScreen
    visible: persist.onscreen

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

    PersistentProperties {
        id: persist
        reloadableId: "persist-StartPanel"

        property bool onscreen: false
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overlay-qs-start"
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
        // opacity: 1
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
            }

            RowLayout {
                id: powerRow
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

                    Item {
                        required property var modelData
                        width: childrenRect.width
                        height: childrenRect.height
                        HoldButton {
                            symbol: parent.modelData.text
                            onActivated: () => {
                                Quickshell.execDetached(parent.modelData.action);
                                // This hackyness is nessary to prevent weird behavior when the window is ripped out from under it
                                // only really relevent for the lock and suspend actions
                                enabled = false;
                                persist.onscreen = false;
                                enabled = true;
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

                    Text {
                        Layout.row: 0
                        Layout.column: 1
                        Layout.preferredWidth: 40
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        text: {
                            if (!Idle.enabled) {
                                return "󰒳 ";
                            } else {
                                return "";
                            }
                        }
                        font.pixelSize: 16
                        font.family: "JetBrainsMonoNF"
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

                onMiddleClicked: () => {
                    Idle.enabled = !Idle.enabled;
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
                    text: "Placeholder" + "\n" + "line 2"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 24
                    color: Colours.white
                }
            }
        }
    }
}
