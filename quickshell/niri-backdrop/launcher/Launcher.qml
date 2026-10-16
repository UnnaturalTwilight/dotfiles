// Launcher.qml
// Based on: https://github.com/Afillated/quickshell-carbonflake/blob/main/panels/Launcher.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.widgets

// PopupWindow {
PanelWindow {
    id: launcher
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"
    visible: false

    property bool isOpen: false
    property real fontSize
    property real initialHeight

    onIsOpenChanged: {
        if (isOpen === true) {
            input.text = "";
            input.forceActiveFocus();
            visible = true;
        } else {
            visible = false;
            resetState();
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            console.log("Launcher toggle");
            if (launcher.isOpen) {
                closeAnim.start();
            } else {
                launcher.isOpen = true;
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: launcher.visible
        onActivated: {
            closeAnim.start();
        }
    }

    readonly property real calcHeight: initialHeight * 3
    readonly property int maxEntries: 5
    readonly property real entryHeight: (initialHeight * 1.5)
    //(height - ((initialHeight * 1.2) + fontSize)) / maxEntries

    property string text: ""
    property string sentQuery: ""
    property string sentProvider: "desktopapplications"
    property var pending: []
    property int resultCount: 0
    property string calcResult: ""
    property string calcExpr: ""
    readonly property bool calcMode: text.startsWith("=")

    function resetState() {
        text = "";
        sentQuery = "";
        pending = [];
        results.clear();
        resultCount = 0;
        calcResult = "";
        calcExpr = "";
    }

    ListModel {
        id: results
    }

    Process {
        id: bridge
        command: [Quickshell.shellDir + "/launcher/elephant-bridge.py"]
        running: launcher.isOpen
        stdinEnabled: true
        stdout: SplitParser {
            onRead: line => {
                const msg = JSON.parse(line);
                if (msg.type === "error") {
                    console.warn("elephant:", msg.message);
                    return;
                }
                if (msg.query !== launcher.sentQuery) {
                    return;
                }
                if (msg.type === "item") {
                    if (msg.item.provider === launcher.sentProvider) {
                        launcher.pending.push(msg.item);
                    }
                } else if (msg.type === "done") {
                    launcher.showResults();
                }
            }
        }
    }

    function search(t) {
        if (t === "") {
            resetState();
            return;
        }
        text = t;
        const calc = t.startsWith("=");
        sentProvider = calc ? "calc" : "desktopapplications";
        sentQuery = calc ? t.slice(1).trim() : t.trim();
        pending = [];

        if (sentQuery === "" && calc) {
            results.clear();
            resultCount = 0;
            calcResult = "";
            calcExpr = "";
            return;
        }
        bridge.write(JSON.stringify({
            op: "query",
            providers: [sentProvider],
            query: sentQuery,
            max: calc ? 5 : 30
        }) + "\n");
    }

    function showResults() {
        const isCalc = sentProvider === "calc";
        if (!isCalc) {
            pending.sort((a, b) => (b.score ?? 0) - (a.score ?? 0));
        }

        results.clear();
        for (const it of pending) {
            results.append({
                identifier: it.identifier,
                text: it.text,
                subtext: it.subtext ?? "",
                icon: it.icon ?? "",
                provider: it.provider,
                action: (it.actions ?? [])[0] ?? ""
            });
        }
        if (isCalc) {
            calcResult = pending.length ? pending[0].text : "";
            calcExpr = pending.length ? (pending[0].subtext ?? "") : "";
        }
        resultCount = results.count;
        list.currentIndex = results.count > 0 ? 0 : -1;
    }

    function activate(idx) {
        const i = idx ?? (calcMode ? 0 : list.currentIndex);
        if (i < 0 || i >= results.count) {
            return;
        }
        const it = results.get(i);
        if (!it.action) {
            return;
        }
        bridge.write(JSON.stringify({
            op: "activate",
            provider: it.provider,
            identifier: it.identifier,
            action: it.action,
            query: sentQuery
        }) + "\n");
        closeAnim.start();
    }

    SequentialAnimation {
        id: closeAnim

        ParallelAnimation {
            NumberAnimation {
                target: launchRec
                property: "scale"
                to: 0.8
                duration: 169
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: launchRec
                property: "opacity"
                to: 0.5
                duration: 120
                easing.type: Easing.OutCirc
            }
        }

        ScriptAction {
            script: {
                launcher.isOpen = false;
            }
        }
    }

    ClippingRectangle {
        id: launchRec
        color: Colours.polar1
        border {
            width: 2
            color: Colours.aurora1
        }
        anchors {
            top: parent.top
            topMargin: 300
            right: parent.right
            left: parent.left
        }
        height: {
            if (launcher.calcMode) {
                return launcher.calcHeight + launcher.initialHeight * 1.2;
            } else if (results.count > 0 && !launcher.calcMode) {
                let visibleCount = Math.min(results.count, launcher.maxEntries);
                return (launcher.initialHeight * 1.2) + (visibleCount * launcher.entryHeight) + launcher.fontSize;
            } else {
                return launcher.initialHeight * 1.2;
            }
        }
        radius: launcher.initialHeight / 3
        scale: launcher.isOpen ? 1 : 0.8
        opacity: launcher.isOpen ? 1 : 0.5

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

        ClippingRectangle {
            id: inputBox
            color: "transparent"
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }
            implicitHeight: launcher.initialHeight * 1.2

            TextInput {
                id: input
                // anchors.fill: parent
                anchors.left: icon.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: launcher.fontSize / 2
                verticalAlignment: TextInput.AlignVCenter
                color: Colours.snow0
                font.pixelSize: launcher.fontSize * 1.2
                clip: true

                onTextChanged: launcher.search(text)
                Keys.onPressed: e => {
                    if (e.key === Qt.Key_Down) {
                        list.incrementCurrentIndex();
                    } else if (e.key === Qt.Key_Up) {
                        list.decrementCurrentIndex();
                    } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                        launcher.activate();
                    } else {
                        return;
                    }
                    e.accepted = true;
                }
            }

            SvgIcon {
                id: icon
                anchors {
                    left: parent.left
                    verticalCenter: input.verticalCenter
                    margins: launcher.fontSize / 2
                }
                iconName: "search"
                colour: Colours.gray
                size: launcher.fontSize * 1.6
            }

            Text {
                visible: input.text === ""
                anchors {
                    left: icon.right
                    verticalCenter: input.verticalCenter
                    margins: launcher.fontSize / 2
                }
                verticalAlignment: Text.AlignVCenter
                text: "Find or Calculate with ="
                color: Colours.polar5
                font.pixelSize: launcher.fontSize * 1.2
                elide: Text.ElideRight
            }
        }

        ListView {
            id: list
            visible: !launcher.calcMode && results.count > 0
            clip: true
            model: results
            boundsBehavior: Flickable.StopAtBounds
            anchors {
                top: inputBox.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10 //launcher.fontSize / 2
            }

            delegate: Rectangle {
                id: entry
                width: list.width
                height: launcher.entryHeight
                radius: launcher.initialHeight / 3
                color: ListView.isCurrentItem ? Colours.highlight : "transparent"

                required property string icon
                required property string text
                required property string subtext
                required property int index

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4 //launcher.fontSize / 2
                    spacing: launcher.fontSize * 0.75

                    IconImage {
                        implicitSize: Math.round(launcher.entryHeight * 0.6)
                        source: Quickshell.iconPath(entry.icon, "application-x-executable")
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: entry.text
                            color: Colours.snow0
                            font.pixelSize: launcher.fontSize * 1.1
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: entry.subtext
                            color: Colours.text
                            font.pixelSize: launcher.fontSize * 0.8
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: list.currentIndex = entry.index
                    onClicked: launcher.activate(entry.index)
                }
            }
        }

        ClippingRectangle {
            id: calcRec
            visible: launcher.calcMode
            anchors {
                top: inputBox.bottom
                right: parent.right
                left: parent.left
            }
            height: launcher.calcHeight
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width
                spacing: launcher.fontSize / 2

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: launcher.calcResult !== "" ? launcher.calcResult : "…"
                    color: Colours.text
                    font.pixelSize: launcher.fontSize * 3
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: launcher.fontSize
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: launcher.calcExpr
                    color: Colours.gray
                    font.pixelSize: launcher.fontSize
                    elide: Text.ElideRight
                }
            }
        }
    }
}
