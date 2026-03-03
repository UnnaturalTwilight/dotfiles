// SysMenu.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

MenuItem {
    id: root
    required property QsMenuEntry modelData
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredHeight: enabled ? 30 : 5
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

    // text: root.modelData?.text
    onClicked: root.modelData.triggered()
    enabled: !root.modelData?.isSeparator

    height: enabled ? implicitHeight : 6

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        radius: 6
        color: !root.modelData?.isSeparator ? "transparent" : Qt.alpha(Colours.darkGray, 0.6)
    }

    background: Rectangle {
        radius: 12
        color: root.hovered && !root.modelData?.isSeparator ? Qt.alpha(Colours.pinkish, 0.5) : "transparent"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: root.modelData?.text
        color: parent.enabled ? Colours.white : Colours.kindaGray
    }

    CheckBox {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5
        visible: root.modelData?.buttonType !== QsMenuButtonType.None
        checked: root.modelData?.checkState
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 15
        text: root.modelData?.hasChildren ? "▶" : ""
        color: Colours.kindaGray
    }

    QsMenuOpener {
        id: submenuOpener
        menu: root.modelData
    }
}
