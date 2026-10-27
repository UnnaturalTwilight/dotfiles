// ResultEntry.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services.launcher
import qs.widgets

Rectangle {
    id: entry

    required property int fontSize
    required property int baseHeight
    required property var modelData
    required property int index

    required property string identifier
    required property string provider
    required property string text
    property string subtext: modelData?.subtext ?? ""
    property string icon: modelData?.icon ?? ""
    property string type: modelData?.type ?? ""
    property bool active: modelData?.active ?? true
    property var hints: modelData?.hints ?? ({})
    property var buttons: modelData?.actions?.buttons ?? ({})

    property string fontFamily: hints?.monospace ? Fonts.mono : Fonts.sans
    property string imageSource: hints?.preview_type === "image" ? (hints?.preview ?? "") : ""

    // Standard entry height is baseHeight * 1.5
    implicitHeight: (entry.hints?.autoHeight ?? false) ? (resultRow.implicitHeight + 8) : (entry.baseHeight * 1.5)
    radius: 8
    color: ListView.isCurrentItem ? Colours.highlight : "transparent"
    border.color: "transparent"
    border.width: 2

    RowLayout {
        id: resultRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 4
        }
        height: (entry.hints?.autoHeight ?? false) ? implicitHeight : (entry.height - 8)

        Item {
            id: providerIcon
            visible: entry.icon !== "" || (entry.buttons?.icon ?? false)
            Layout.preferredHeight: entry.implicitHeight * 0.6
            Layout.preferredWidth: entry.implicitHeight * 0.6
            opacity: (entry.hints?.active ?? true) ? 1 : 0.6

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            IconImage {
                Layout.rightMargin: entry.fontSize * 0.25
                visible: entry.icon !== "" && !entry.buttons?.icon
                implicitSize: Math.round(entry.implicitHeight * 0.6)
                source: visible ? Quickshell.iconPath(entry.icon, "application-x-executable") : ""
            }

            FlatButton {
                Layout.rightMargin: entry.fontSize * 0.25
                visible: entry.buttons?.icon ?? false
                iconSize: Math.round(entry.implicitHeight * 0.6)
                anchors.centerIn: parent
                focusPolicy: Qt.NoFocus
                mode: "icon"

                background: null
                padding: 0
                radius: 12

                text: entry.buttons?.icon?.text ?? entry.buttons?.icon?.action ?? "Button"
                iconName: entry.buttons?.icon?.icon ?? "unknown"

                onClicked: LauncherState.activate(entry.index, entry.buttons?.icon ?? {}, entry.buttons?.icon?.action ?? "")
            }
        }

        ColumnLayout {
            id: textColumn
            visible: text.visible || subtext.visible || clipboardImage.visible
            Layout.fillWidth: entry.hints?.buttonRowAlign !== "left"
            Layout.minimumWidth: 0
            spacing: 0
            opacity: (entry.hints?.active ?? true) ? 1 : 0.6

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            Image {
                id: clipboardImage
                Layout.fillWidth: true
                Layout.preferredHeight: status === Image.Ready ? implicitHeight : entry.fontSize * 3
                visible: entry.imageSource !== "" && status !== Image.Error
                source: entry.imageSource
                sourceSize: Qt.size(Math.max(1, Math.min(640, Math.floor(width))), 180)
                asynchronous: true
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignLeft
            }

            Text {
                id: text
                Layout.fillWidth: true
                visible: entry.text !== ""
                text: entry.text
                color: entry.ListView.isCurrentItem ? Colours.white : Colours.snow2
                font.family: entry.fontFamily
                font.pixelSize: entry.fontSize * 1.1
                wrapMode: (entry.hints?.textWrap ?? false) ? Text.Wrap : Text.NoWrap
                maximumLineCount: entry.hints?.maxLines ?? 1
                elide: Text.ElideRight
            }

            Text {
                id: subtext
                Layout.fillWidth: true
                visible: entry.subtext !== ""
                text: entry.subtext
                color: Colours.gray
                font.family: entry.fontFamily
                font.pixelSize: entry.fontSize * 0.8
                elide: Text.ElideRight
            }
        }

        RowLayout {
            id: buttonsRow
            Layout.fillWidth: false
            Layout.alignment: entry.hints?.buttonRowAlign === "left" ? Qt.AlignLeft : Qt.AlignRight
            visible: entry.buttons?.row?.length > 0
            enabled: visible

            Repeater {
                model: entry.buttons?.row ?? []

                FlatButton {
                    required property var modelData
                    implicitHeight: mode === "icon" ? iconSize : (entry.fontSize * 1.6)
                    implicitWidth: mode === "icon" ? iconSize : (contentItem.implicitWidth + (padding * 2))
                    focusPolicy: Qt.NoFocus

                    mode: modelData?.type || "text"
                    text: modelData?.text ?? modelData?.action ?? "Button"
                    iconName: modelData?.icon ?? "unknown"
                    checked: modelData?.checked ?? false
                    destructive: modelData?.destructive ?? false

                    iconSize: entry.fontSize * (modelData?.large ? 2.4 : (modelData?.type === "checkbox" ? 1.2 : 1.6))

                    onClicked: LauncherState.activate(entry.index, modelData, modelData?.action)
                }
            }
        }

        ColumnLayout {
            id: buttonsColumn
            visible: entry.buttons?.column?.length > 0
            enabled: buttonsColumn.visible
            spacing: 2

            Repeater {
                model: entry.buttons?.column ?? []

                FlatButton {
                    required property var modelData
                    implicitHeight: entry.fontSize * 1.6
                    implicitWidth: entry.fontSize * 1.6
                    focusPolicy: Qt.NoFocus

                    mode: modelData?.type || "text"
                    text: modelData?.text ?? modelData?.action ?? "Button"
                    iconName: modelData?.icon ?? "unknown"
                    destructive: modelData?.destructive ?? false

                    onClicked: LauncherState.activate(entry.index, modelData, modelData?.action)
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 8
            visible: entry.hints?.prefix ?? false
            implicitWidth: prefixLabel.implicitWidth + 16
            implicitHeight: prefixLabel.implicitHeight + 8
            radius: 4
            color: Colours.shadow
            border {
                width: 2
                color: Colours.power5
            }

            Text {
                id: prefixLabel
                anchors.centerIn: parent
                text: entry.hints?.prefix?.replace(/^ /, "󱁐") ?? ""
                textFormat: Text.PlainText
                color: Colours.text
                font.family: Fonts.nerdMono
                font.pixelSize: entry.fontSize * 1.1
            }
        }
    }

    Text {
        id: debugButtonData
        visible: LauncherState.debugRendering
        anchors.right: parent.right
        anchors.left: parent.left
        horizontalAlignment: Text.AlignRight
        color: Colours.power2
        font.family: Fonts.mono
        font.pixelSize: entry.fontSize / 2
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: JSON.stringify(entry.modelData?.actions).replace(/},{/g, "},\n{")
    }
}
