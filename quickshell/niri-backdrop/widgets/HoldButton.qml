// HoldButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import qs.config

DelayButton {
    id: root
    required property string symbol
    property int buttonSize: 60

    property color bgColor: "transparent"
    property color bgColorHover: Colours.highlight
    property color borderColor: Colours.polar2
    property color fgColor: Colours.gray
    property color activeColor: Colours.power1

    text: root.symbol
    font.pixelSize: root.buttonSize * 0.8
    font.family: Fonts.nerdMono
    delay: 1000
    implicitHeight: buttonSize
    implicitWidth: buttonSize

    contentItem: Text {
        anchors.centerIn: parent
        text: root.text
        font: root.font
        color: root.hovered ? root.activeColor : root.fgColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        anchors.centerIn: parent
        implicitWidth: parent.width
        implicitHeight: parent.height
        radius: root.buttonSize / 4
        color: root.bgColor
        border.color: root.borderColor
        border.width: 2
    }

    Shape {
        anchors.centerIn: parent
        implicitWidth: parent.width
        height: parent.height
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            property int lineweight: 4
            //p = 2 * [ a + b - r * ( 4 - π ) ]
            property real perimeter: 2 * (2 * root.buttonSize - (root.buttonSize / 4) * (4 - Math.PI))
            strokeWidth: lineweight
            strokeColor: root.hovered ? Colours.power1 : Colours.polar2
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
            fillColor: root.hovered ? root.bgColorHover : "transparent"
        }
    }
}
