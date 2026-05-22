// Overlay.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.utils.notify

Scope {
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
            item: notificationStack
            radius: 20
        }

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
