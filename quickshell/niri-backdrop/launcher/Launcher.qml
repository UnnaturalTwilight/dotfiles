// Launcher.qml
// V2 implementation
// Orignaly based on: https://github.com/Afillated/quickshell-carbonflake/blob/main/panels/Launcher.qml
// V1 was mostly vibecoded
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls

import qs.config
import qs.services
import qs.services.launcher
import qs.widgets

// qmllint disable
PanelWindow {
// qmllint enable
    id: launcher
    screen: LauncherState.followMouse ? System.focusedScreen : LauncherState.screen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "launcher-qs"
    color: "transparent"
    surfaceFormat.opaque: false
    visible: LauncherState.open
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    property real contentWidth: 700
    property real fontSize: 20
    property real baseHeight: 50
    property real topSpacing: 300
    property int maxEntries: 5

    onVisibleChanged: {
        if (visible) {
            input.forceActiveFocus();
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: launcher.visible
        onActivated: closeAnimation.start()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: closeAnimation.start()
    }

    Binding {
        target: LauncherState
        property: "view"
        restoreMode: Binding.RestoreBindingOrValue
        value: ({
            input: input,
            list: resultsView,
            closeAnim: closeAnimation,
            launchRec: content,
            height: launcher.height,
            fontSize: launcher.fontSize,
            baseHeight: launcher.baseHeight,
        })
    }

    SequentialAnimation {
        id: closeAnimation

        ParallelAnimation {
            NumberAnimation {
                target: content
                property: "scale"
                to: 0.8
                duration: 169
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: content
                property: "opacity"
                to: 0.5
                duration: 120
                easing.type: Easing.OutCirc
            }
        }

        ScriptAction {
            script: LauncherState.open = false
        }
    }

    Rectangle {
        id: content
        z: 1
        width: Math.min(launcher.contentWidth, parent.width)
        height: {
            const headerHeight = launcher.baseHeight * 1.2 + providerBar.height + errorText.height;
            const entryHeight = launcher.baseHeight * 1.5;
            if (LauncherState.results.count > 0) {
                const margins = resultsView.anchors.topMargin + resultsView.anchors.bottomMargin;
                const available = Math.max(0, launcher.height - content.anchors.topMargin - headerHeight - /* preview.height - */ margins - launcher.fontSize);
                const resultsHeight = Math.min(resultsView.contentHeight || entryHeight, launcher.maxEntries * entryHeight, available);
                return headerHeight /* + preview.height */ + resultsHeight + margins - 10;
            } else {
                return headerHeight /* + preview.height */;
            }
        }
        anchors {
            top: parent.top
            topMargin: launcher.topSpacing
            horizontalCenter: parent.horizontalCenter
        }
        scale: LauncherState.open ? 1 : 0.8
        color: Colours.polar1
        opacity: LauncherState.open ? 1 : 0.5
        radius: 12
        border.width: 3
        border.color: Colours.aurora4

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCirc
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            // Consume clicks on empty parts of the window
            onClicked: (e) => { e.accepted = true }
        }

        Item {
            id: inputBox
            implicitHeight: launcher.baseHeight * 1.2
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }

            TextField {
                id: input
                anchors {
                    left: icon.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: launcher.fontSize / 2
                }
                verticalAlignment: TextInput.AlignVCenter
                color: Colours.snow2
                selectionColor: Colours.power4
                selectedTextColor: Colours.white
                font.family: Fonts.sans
                font.pixelSize: launcher.fontSize * 1.2
                padding: 0
                clip: true

                background: null

                placeholderText: LauncherState.activeProviderData?.prompt ??
                    LauncherState.activeProviderData?.name ?? ""
                placeholderTextColor: Colours.polar5

                onTextChanged: LauncherState.search(text)
                Keys.onPressed: (e) => {
                    switch (e.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            LauncherState.activate(resultsView.currentIndex, {
                                type: 'keyboard',
                                key: 'enter',
                                shift: e.modifiers & Qt.ShiftModifier,
                                ctrl: e.modifiers & Qt.ControlModifier,
                                alt: e.modifiers & Qt.AltModifier,
                            });
                            break;
                        case Qt.Key_Tab:
                            LauncherState.autocomplete(resultsView.currentIndex, {
                                type: 'keyboard',
                                key: 'tab',
                                shift: e.modifiers & Qt.ShiftModifier,
                                ctrl: e.modifiers & Qt.ControlModifier,
                                alt: e.modifiers & Qt.AltModifier,
                            });
                            break;
                        case Qt.Key_Backspace:
                            if (text === "") {
                                LauncherState.back();
                            } else { return; }
                            break;
                        case Qt.Key_Up:
                            resultsView.decrementCurrentIndex();
                            break;
                        case Qt.Key_Down:
                            resultsView.incrementCurrentIndex();
                            break;
                        // CLEANUP: the following are clear examles of "if its stupid and it works..."
                        case Qt.Key_Equal: // For my drawing tablet <Ctrl-Equal> acts as PageUp
                            if (!(e.modifiers & Qt.ControlModifier)) { return; }
                            // fallthrough
                        case Qt.Key_PageUp:
                            resultsView.keyNavigationWraps = false;
                            for (let i = 0; i < (launcher.maxEntries - 2); i++) {
                                resultsView.decrementCurrentIndex();
                            }
                            resultsView.keyNavigationWraps = true;
                            resultsView.decrementCurrentIndex();
                            break;
                        case Qt.Key_Minus: // For my drawing tablet <Ctrl-Minus> acts as PageDown
                            if (!(e.modifiers & Qt.ControlModifier)) { return; }
                            // fallthrough
                        case Qt.Key_PageDown:
                            resultsView.keyNavigationWraps = false;
                            for (let i = 0; i < (launcher.maxEntries - 2); i++) {
                                resultsView.incrementCurrentIndex();
                            }
                            resultsView.keyNavigationWraps = true;
                            resultsView.incrementCurrentIndex();
                            break;
                        default:
                            return;
                    }
                    e.accepted = true;
                }
            }

            Item {
                id: icon
                width: launcher.fontSize * 1.6
                height: width
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: launcher.fontSize / 2
                }

                SvgIcon {
                    anchors.centerIn: parent
                    visible: LauncherState.activeProviderData?.svg !== undefined
                    iconName: LauncherState.activeProviderData?.svg || "unknown"
                    colour: Colours.gray
                    opacity: throbber.visible ? 0.3 : 1
                    size: parent.height
                }

                Image {
                    anchors.fill: parent
                    visible: LauncherState.activeProviderData?.svg === undefined
                    opacity: throbber.visible ? 0.3 : 1
                    source: Quickshell.iconPath(LauncherState.activeProviderData?.icon, "applications-other")

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.Linear
                        }
                    }
                }

                BusyIndicator {
                    // TODO: Less aggressive
                    // Maybe replace with an indeterminate progress bar between the textInput and ProviderBar
                    id: throbber
                    z: 2
                    anchors.centerIn: parent
                    visible: LauncherState.working
                    running: LauncherState.working
                }
            }

            Text {
                id: debugData
                visible: LauncherState.debugRendering
                anchors.right: parent.right
                anchors.left: parent.left
                horizontalAlignment: Text.AlignRight
                color: Colours.power2
                font.family: Fonts.mono
                font.pixelSize: launcher.fontSize / 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: JSON.stringify({
                    provider: LauncherState.activeProviderId,
                    cachedPrefix: LauncherState.cachedPrefix,
                    prefixActive: LauncherState.prefixActive,
                    debugRendering: LauncherState.debugRendering,
                    debugMode: System.debugMode,
                }) + "\n" + JSON.stringify({ query: LauncherState.searchTerm })
            }
        }

        ProviderBar {
            id: providerBar
            anchors {
                top: inputBox.bottom
                left: parent.left
                right: parent.right
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
                topMargin: -10
            }
            fontSize: launcher.fontSize
        }

        Text {
            id: errorText
            visible: LauncherState.errorMessage !== ""
            height: visible ? launcher.fontSize * 1.1 : 0
            anchors {
                top: providerBar.bottom
                horizontalCenter: parent.horizontalCenter
            }

            text: LauncherState.errorMessage
            font.family: Fonts.sans
            font.pixelSize: launcher.fontSize * 0.8
            color: Colours.aurora0
        }

        ListView {
            id: resultsView
            model: LauncherState.results

            anchors {
                top: errorText.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: true
            keyNavigationWraps: true

            // FIXME: IDK if this is a good idea
            // currently using this to autoscroll the view but handling the displayed highlight on the delegate
            // highlight: Rectangle {
            //     radius: 8
            //     color: Colours.highlight
            // }
            highlightMoveDuration: 250
            highlightMoveVelocity: 600

            // TODO: ScrollIndicator

            // TODO: use ObjectModel to give providers control of how delegates are formatted??
            // https://doc.qt.io/qt-6/qml-qtqml-models-objectmodel.html
            // or use DelegateChooser to select a delegate based on the model data??
            // -> this would work well with the type/display props on entries
            // https://doc.qt.io/qt-6/qml-qtqml-models-delegatechooser.html
            delegate: ListEntry {
                width: resultsView.width
                fontSize: launcher.fontSize
                baseHeight: launcher.baseHeight
            }
        }
    }
}
