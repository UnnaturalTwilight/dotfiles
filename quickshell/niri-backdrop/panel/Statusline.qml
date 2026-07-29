// Statusline.qml

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services
import qs.services.notifications
import qs.widgets

Rectangle {
    id: status

    property int margin: 10

    implicitHeight: 30

    color: Colours.power5
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

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: dateText.left
        anchors.rightMargin: parent.margin

        SvgIcon {
            id: dndIcon
            iconName: "states/do-not-disturb_on"
            colour: Colours.gray
            size: 32
            scale: 0.5
            Layout.preferredWidth: size
            Layout.preferredHeight: size
            Layout.margins: -8
            visible: NotifServer.doNotDisturb
        }

        SvgIcon {
            id: musicIcon
            iconName: "music"
            colour: Colours.gray
            size: 40
            scale: 0.5
            Layout.preferredWidth: size
            Layout.preferredHeight: size
            Layout.margins: -10
            visible: Music.playing
        }

        SvgIcon {
            id: networkIcon
            iconName: Network?.connectionIcon ?? "network/wifi_off"
            colour: Colours.gray
            size: 20
            Layout.preferredWidth: size
            Layout.preferredHeight: size
        }
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
