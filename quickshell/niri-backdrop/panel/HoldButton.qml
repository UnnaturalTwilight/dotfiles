// HoldButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs

DelayButton {
    id: root
    required property string symbol
    property int buttonSize: 60

    text: root.symbol
    font.pixelSize: 48
    font.family: "JetBrainsMonoNFM"
    delay: 1000
    implicitHeight: buttonSize
    implicitWidth: buttonSize

    contentItem: Text {
        anchors.centerIn: parent
        text: root.text
        font: root.font
        color: root.hovered ? Colours.pinkish : Colours.kindaGray
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Shape {
        anchors.centerIn: parent
        implicitWidth: parent.width
        height: parent.height
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            property int lineweight: 4
            //p = 2 * [ a + b - r * ( 4 - π ) ]
            property real perimeter: 2 * (2 * root.buttonSize - (root.buttonSize / 4) * (4 - Math.PI))
            strokeWidth: lineweight
            strokeColor: root.hovered ? Colours.pinkish : Colours.kindaGray
            strokeStyle: ShapePath.DashLine
            dashPattern: [root.progress * (perimeter / lineweight), (perimeter / lineweight) - (root.progress * (perimeter / lineweight))]
            dashOffset: -(root.buttonSize / 4) / lineweight
            startX: 0
            startY: 0
            PathRectangle {
                width: root.buttonSize
                height: root.buttonSize
                radius: root.buttonSize / 4
                bevel: false
            }
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
        }
    }
}
