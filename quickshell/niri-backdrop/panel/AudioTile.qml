// AudioTile.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.panel

InfoTile {
    id: audioTile
    vSize: 80
    icon: WrapperMouseArea {
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        Text {
            id: audioIcon
            anchors.centerIn: parent
            verticalAlignment: Text.AlignVCenter
            text: Audio.icon
            font.pixelSize: 56
            font.family: "JetBrainsMonoNFM"
            color: parent.containsMouse ? Colours.pinkish : Colours.kindaGray
        }
        hoverEnabled: true
        onClicked: Audio.setMuted(!Audio.muted) 
    }

    info: GridLayout {
        columns: 2
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
            model: Audio.ready ? Audio.sinks?.map(s => ({value: s.name, text: s.description})).filter(d => d.description != "") : [Audio.description]
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
            rightPadding: 6
            font.pixelSize: 16
            font.family: "JetBrainsMonoNF"
            font.bold: hovered
            hoverEnabled: true

            delegate: ItemDelegate {
                id: delegate

                required property var model
                required property int index

                width: dropdown.width
                contentItem: WrapperRectangle {
                    anchors.fill: parent
                    color: delegate.highlighted ? Qt.alpha(Colours.pinkish, 0.5) : "transparent"
                    leftMargin: 5
                    rightMargin: 5
                    topMargin: 0
                    bottomMargin: 0
                    Text {
                        text: delegate.model[dropdown.textRole]
                        color: Colours.white
                        font: dropdown.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
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
                color: dropdown.hovered ? Colours.pinkish : Colours.kindaGray
                width: 12
            }

            contentItem: Text {
                leftPadding: 0
                rightPadding: dropdown.indicator.width + dropdown.spacing
                text: dropdown.displayText
                font: dropdown.font
                color: dropdown.hovered ? Colours.pinkish : Colours.white
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
                    border.color: Colours.niri_float
                    border.width: 3
                    radius: 4
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
            font.family: "JetBrainsMonoNF"
            color: Colours.white
        }

        PercentSlider {
            id: volumeSlider
            Layout.row: 1
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            value: Audio.volume
            active: !Audio.muted
            onValueSet: (v) => Audio.setVolume(v)
        }
    }
}
