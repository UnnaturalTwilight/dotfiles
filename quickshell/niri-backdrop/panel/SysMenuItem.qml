// SysMenu.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

MenuItem {
    id: root
    required property QsMenuEntry modelData
    property color highlightColor: Qt.alpha(Colours.darkViolet, 0.8)
    Layout.fillWidth: true
    Layout.fillHeight: true
    // Layout.preferredHeight: !root.modelData?.isSeparator ? 30 : 5
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

    text: root.modelData?.text ?? ""
    onClicked: root.modelData.triggered()
    enabled: (!root.modelData?.isSeparator && root.modelData?.enabled) ?? false
    hoverEnabled: root.enabled
    checked: root.modelData?.checkState ?? false
    height: !root.modelData?.isSeparator ? label.implicitHeight : 6

    // Separator
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        radius: 6
        color: !root.modelData?.isSeparator ? "transparent" : Qt.alpha(Colours.darkGray, 0.6)
    }

    // Content
    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: root.text
        color: parent.enabled ? Colours.white : Colours.kindaGray
        width: parent.width - 10
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.family: "Noto Sans"
        font.pixelSize: 16
    }
    
    // Everything this is supposed to do is just done with the Text above
    contentItem: null

    arrow: Text {
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        anchors.right: parent.right
        anchors.rightMargin: 15
        text: root.modelData?.hasChildren ? "󰦺" : ""
        font.family: "JetBrainsMonoMF"
        font.pixelSize: 20
        color: Colours.kindaGray
    }

    indicator: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.height - 6
        height: parent.height - 6
        radius: root.modelData?.buttonType === QsMenuButtonType.CheckBox ? 4 : (parent.height - 6) / 2
        color: root.checked ? Colours.navy : Colours.darkGray
        border.color: Qt.alpha(Colours.kindaGray, 0.5)
        border.width: 2
        visible: root.modelData?.buttonType !== QsMenuButtonType.None

        Text {
            anchors.centerIn: parent
            text: root.modelData?.buttonType === QsMenuButtonType.CheckBox ? "" : ""
            font.family: "JetBrainsMonoMFM"
            font.pixelSize: 9
            color: Colours.kindaGray
            visible: root.checked
        }
    }

    background: Rectangle {
        radius: 12
        color: root.hovered ? root.highlightColor : "transparent"
    }
}
