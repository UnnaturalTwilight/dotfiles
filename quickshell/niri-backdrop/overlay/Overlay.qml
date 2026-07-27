// Overlay.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.services
import qs.services.notifications

PanelWindow {
    id: overlayPanel
    screen: modelData
    property var modelData

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "overlay-qs-" + modelData.name
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    mask: Region {
        item: System.panelVisible ? null : notificationStack.contentItem
        radius: 20
        regions: System.panelVisible ? panels.maskZone : null
    }

    BackgroundEffect.blurRegion: System.panelVisible ? panels.blurZone : notifBlurZone

    Region {
        id: notifBlurZone
        regions: notifBlurRegions.instances
    }

    Variants {
        id: notifBlurRegions
        model: {
            notificationStack.contentItem.visibleChildren.filter(child => child instanceof Rectangle);
        }

        delegate: Region {
            required property Item modelData
            item: modelData
            radius: 20
        }
    }

    Panels {
        id: panels
        // screen: modelData
        visible: System.panelVisible
    }

    ListView {
        id: notificationStack
        visible: !System.panelVisible

        x: overlayPanel.modelData?.width - (40 + implicitWidth)
        y: 40
        implicitWidth: 400
        implicitHeight: overlayPanel.modelData?.height - 40
        spacing: 10

        interactive: false

        model: ScriptModel {
            values: NotifServer.list.filter(notif => notif.onscreen)
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

    Loader {
        id: osdLoader
        x: (overlayPanel.modelData?.width - 400) / 2
        y: overlayPanel.modelData?.height - 100

        sourceComponent: OSD {
            id: brightnessOsd
            value: Brightness.screenValue
            icon: "󰃟 "

            Connections {
                target: Brightness
                function onShowBrightnessOsd(): void {
                    brightnessOsd.showOsd();
                }
            }
        }
        active: (overlayPanel.modelData === System.primaryScreen)
    }
}
