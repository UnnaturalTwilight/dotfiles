// Start.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.utils.niri
import qs.widgets

Scope {
    id: startScope

    property alias screen: startPanel.screen
    property alias onscreen: persist.onscreen

    IpcHandler {
        id: startIPC
        target: "start"

        function toggle(): void {
            persist.onscreen = !startScope.onscreen;
        }
        function setVisible(visible: bool): void {
            persist.onscreen = visible;
        }
        function state(): bool {
            return persist.onscreen;
        }
    }

    function closePanel(): void {
        systray.activeMenu = null;
        persist.onscreen = false;
    }

    PersistentProperties {
        id: persist
        reloadableId: "StartPanel"

        property bool onscreen: false
    }

    PanelWindow {
        id: startPanel
        // required property ShellScreen modelData
        visible: persist.onscreen

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
            color: Colours.polar1
            // opacity: 1
            radius: 12
            implicitWidth: 420

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                GridLayout {
                    columns: 3
                    rowSpacing: 3
                    Layout.rightMargin: 20
                    Layout.fillWidth: true

                    Image {
                        id: profilePic
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
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.row: 1
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: Quickshell.env("USER") + "@" + System.hostname
                        font.pixelSize: 20
                        font.family: "JetBrainsMonoNF"
                        color: Colours.gray
                    }
                    
                    Spacer {
                        Layout.row: 2
                        Layout.column: 1
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                    }

                    Text {
                        Layout.column: 1
                        Layout.row: 3
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: Network.connectionString
                        font.pixelSize: 20
                        font.family: "JetBrainsMonoNF"
                        color: Colours.gray
                        Component.onCompleted: {
                            Network.refresh();
                        }
                    }

                    Text {
                        Layout.column: 2
                        Layout.row: 3
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        text: Network.connectionIcon
                        font.pixelSize: 20
                        font.family: "JetBrainsMonoNF"
                        color: Colours.gray
                        Component.onCompleted: {
                            Network.refresh();
                        }
                    }
                }

                PowerRow {}

                Spacer {}

                BatteryTile {}

                AudioTile {}

                SysTray {
                    id: systray
                }

                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    radius: 20
                    color: Colours.polar0

                    Text {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 10
                        text: "Placeholder"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 24
                        color: Colours.text
                    }
                }
            }
        }
    }

    component Spacer: Rectangle {
        color: Colours.polar2
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        implicitHeight: 6
        radius: 10
    }

    component PowerRow: RowLayout {
        id: powerRow
        spacing: 12
        Layout.alignment: Qt.AlignCenter
        property int buttonSize: 48

        HoldButton {
            symbol: ""
            onActivated: () => {
                Quickshell.execDetached(["systemctl", "poweroff"]);
            }
            buttonSize: powerRow.buttonSize
        }

        HoldButton {
            symbol: ""
            onActivated: () => {
                Quickshell.execDetached(["systemctl", "reboot"]);
            }
            buttonSize: powerRow.buttonSize
        }

        HoldButton {
            symbol: "󰤄"
            onActivated: () => {
                Qt.callLater(() => {
                    startScope.closePanel();
                    Idle.suspend();
                });
            }
            buttonSize: powerRow.buttonSize
        }

        HoldButton {
            symbol: "󰜗"
            onActivated: () => {
                Qt.callLater(() => {
                    startScope.closePanel(); 
                    Idle.hibernate();
                });
            }
            buttonSize: powerRow.buttonSize
        }

        HoldButton {
            symbol: ""
            onActivated: () => {
                Idle.lock(false);
                Qt.callLater(() => {
                    startScope.closePanel();
                });
            }
            buttonSize: powerRow.buttonSize
        }

        HoldButton {
            symbol: ""
            onActivated: () => {
                Niri.quitNiri(true);
                Qt.callLater(() => {
                    startScope.closePanel();
                });
            }
            buttonSize: powerRow.buttonSize
        }
    }
}
