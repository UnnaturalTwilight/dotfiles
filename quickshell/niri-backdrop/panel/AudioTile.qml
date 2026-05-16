// AudioTile.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.widgets

InfoTile {
    id: audioTile
    vSize: 80

    icon: MouseArea {
        implicitHeight: parent.implicitHeight
        implicitWidth: audioIcon.width

        SvgIcon {
            id: audioIcon
            iconName: Audio.icon
            size: Audio.extraProps.iconDisplaySize - 24
            anchors.centerIn: parent

            opacity: Audio.muted ? 0.5 : 1.0
            colour: parent.containsMouse ? Colours.power1 : Colours.gray
        }

        hoverEnabled: true
        onClicked: Audio.muted = !Audio.muted
    }

    info: GridLayout {
        rows: 2
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        ComboBox {
            id: dropdown
            Layout.row: 0
            Layout.fillWidth: true
            // This filters out sinks with empty descriptions, In my case this is just a 'sink-input' for mpd
            // If legit sinks have empty descriptions this will cause them to not show up in the dropdown
            // Decriptions can be overridden in wireplumber config anyways
            model: Audio.ready ? Audio.sinks?.map(s => ({
                        value: s.name,
                        text: s.description
                    })).filter(m => m.text != "") : [Audio.description]
            textRole: "text"
            valueRole: "value"

            currentValue: Audio.name
            onActivated: {
                const sink = Audio.sinks.find(s => s.name === dropdown.currentValue);
                if (sink) {
                    // Quickshell.execDetached(["pactl", "set-default-sink", sink.name]);
                    Audio.setDefaultSink(sink);
                    console.log("Switched audio sink to:", sink.name);
                } else {
                    console.warn("Selected audio sink not found:", dropdown.currentValue);
                }
            }
            rightPadding: 0
            font.pixelSize: 16
            font.family: Fonts.mono
            font.bold: hovered
            hoverEnabled: true

            delegate: ItemDelegate {
                id: delegate

                required property var model
                required property int index

                width: dropdown.width
                contentItem: Text {
                    text: delegate.model[dropdown.textRole]
                    color: Colours.white
                    font: dropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: delegate.highlighted ? Colours.highlight : "transparent"
                    width: dropdown.width - dropdown.rightPadding - 6
                    radius: 8
                }
                highlighted: dropdown.highlightedIndex === index
            }

            indicator: Text {
                id: indicatorText
                text: "󰕏"
                font.pixelSize: 16
                font.bold: true
                x: dropdown.width - width - dropdown.rightPadding
                // anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                color: dropdown.hovered ? Colours.power1 : Colours.gray
                width: 12
            }

            contentItem: Text {
                leftPadding: 0
                rightPadding: dropdown.indicator.width + dropdown.spacing
                text: dropdown.displayText
                font: dropdown.font
                color: dropdown.hovered ? Colours.power1 : Colours.white
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: null

            popup: Popup {
                y: dropdown.height
                width: dropdown.width - dropdown.rightPadding
                height: contentItem.implicitHeight + 6
                padding: 3

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: dropdown.popup.visible ? dropdown.delegateModel : null
                    currentIndex: dropdown.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    color: Colours.polar1
                    border.color: Colours.frost0
                    border.width: 2
                    radius: 12
                }
            }
        }

        Text {
            Layout.row: 0
            Layout.column: 1
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: {
                if (Audio.muted) {
                    return " ";
                } else if (Music.playing) {
                    return " ";
                } else {
                    return "";
                }
            }
            font.pixelSize: 16
            font.family: Fonts.nerd
            color: Colours.gray
        }

        Slider {
            id: volumeControl
            value: Audio.volume
            stepSize: 0.02
            wheelEnabled: true

            Layout.row: 1
            Layout.column: 0
            Layout.fillWidth: true

            background: PercentBar {
                id: volumeBar
                Layout.row: 1
                Layout.fillWidth: true
                implicitHeight: 12
                value: volumeControl.visualPosition
                active: !Audio.muted
            }
            handle: null

            onMoved: {
                Audio.volume = volumeControl.position;
            }
        }

        Text {
            id: labelText
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: (Math.round(Audio.volume * 100) + "%").padStart(5, " ")
            font.pixelSize: 16
            font.family: Fonts.mono
            color: Colours.text
        }
    }
}
