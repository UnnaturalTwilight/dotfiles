// Overlay.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils.notify
import qs.utils.niri
import qs.backdrop

Item {
    id: overlayRoot

    property var modelData

    PanelWindow {
        id: overlayPanel
        screen: overlayRoot.modelData

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "overlay-qs-" + overlayRoot.modelData.name
        color: "transparent"
        surfaceFormat.opaque: false

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        mask: Region {
            regions: [notificationRegion]
            // item: hoverTab
        }

        Region {
            id: notificationRegion
            x: notificationStack.x
            y: notificationStack.y + 40
            width: notificationStack.implicitWidth
            height: notificationStack.contentHeight - 40
            radius: 20
        }

        /*
        Item {
            id: hoverTab

            x: overlayRoot.modelData?.width / 2 - (implicitWidth) / 2
            y: expandCounter > 0 ? -10 : 10 - implicitHeight
            // implicitWidth:
            implicitHeight: 80

            // bottomLeftRadius: 10
            // bottomRightRadius: 10

            // color: Colours.shadow
            // border.color: Colours.frost0
            // border.width: 2

            Behavior on y {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            property int expandCounter: 0

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: hoverTab.expandCounter += 1;
                onExited: hoverTab.expandCounter -= 1;
                onClicked: {
                    Niri.toggleOverview();
                }
            }

            Workspaces {
                screen: overlayRoot.modelData
                anchors.centerIn: parent
            }

            Connections {
                target: Niri

                function onOverviewOpenedChanged() {
                    Niri.overviewOpened ? hoverTab.expandCounter += 1 : hoverTab.expandCounter -= 1;;
                }
            }
        }
        */

        ListView {
            id: notificationStack

            x: overlayRoot.modelData?.width - (40 + implicitWidth)
            y: 40
            implicitWidth: 400
            implicitHeight: overlayRoot.modelData?.height - 40
            spacing: 10

            interactive: false

            model: ScriptModel {
                values: Notify.list.filter(notif => notif.onscreen)
            }
            delegate: Notification {}

            add: Transition {
                NumberAnimation {
                    properties: "x"
                    from: 500
                    duration: 250
                    easing.type: Easing.OutQuad
                }
            }

            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 250
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        properties: "x"
                        to: 500
                        duration: 250
                        easing.type: Easing.InQuad
                    }
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }

        BackgroundEffect.blurRegion: blurZone

        Region {
            id: blurZone
            regions: blurRegions.instances
        }

        Variants {
            id: blurRegions
            model: {
                const zones = notificationStack.contentItem.visibleChildren.filter(child => child instanceof Rectangle);
                return zones;
            }

            delegate: Region {
                required property Item modelData
                item: modelData
                radius: 20
            }
        }
    }
}
