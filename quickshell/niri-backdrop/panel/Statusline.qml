// Statusline.qml

import QtQuick

import qs.config
import qs.services
import qs.services.notifications
import qs.widgets

Rectangle {
    id: status

    property int margin: 10

    implicitHeight: 30

    color: Colours.power5 //Qt.alpha(Colours.power5, 0.6)
    border.color: Colours.frost0
    border.width: 2

    Text {
        id: timeText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: parent.margin
        text: Time.time
        color: Colours.gray
        font.pixelSize: 20
        font.family: Fonts.mono
    }

    Text {
        id: dateText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: timeText.left
        anchors.rightMargin: parent.margin
        text: Time.isoDate
        color: Colours.gray
        font.pixelSize: 20
        font.family: Fonts.mono
    }

    Text {
        id: networkIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: dateText.left
        anchors.rightMargin: parent.margin
        text: Network?.connectionIcon ?? ""
        color: Colours.gray
        font.pixelSize: 20
        font.family: Fonts.mono
    }

    SvgIcon {
        id: dndIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: networkIcon.left
        anchors.rightMargin: parent.margin
        iconName: "states/do-not-disturb_on"
        colour: Colours.gray
        size: 20
        visible: NotifServer.doNotDisturb
    }

    Text {
        id: userText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.margin
        text: "󰣇 " + System.username + "@" + System.hostname
        color: Colours.gray
        font.pixelSize: 20
        font.family: Fonts.mono
    }
}
