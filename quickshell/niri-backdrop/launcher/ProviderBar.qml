// ProviderBar.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services.launcher
import qs.widgets

RowLayout {
    id: providerBar

    visible: LauncherState.activeProviderId !== "global" || LauncherState.prefixActive || LauncherState.errorMessage !== ""
    height: visible ? (providerBar.fontSize * 1.5) : 0
    spacing: 8
    property int fontSize: 20

    FlatButton {
        id: globalButton
        text: "Search"
        font.pixelSize: providerBar.fontSize * 0.8
        padding: font.pixelSize / 2
        implicitWidth: font.pixelSize + (padding * 2)
        implicitHeight: font.pixelSize + (padding * 2)
        focusPolicy: Qt.NoFocus

        iconName: "symbols/search"
        iconSize: globalButton.font.pixelSize
        mode: "icon"

        onClicked: LauncherState.openProvider("global");
    }

    FlatButton {
        visible: !LauncherState.prefixActive && LauncherState.activeProviderId !== "providerlist"
        text: "Providers" // FIXME: don't hardcode
        font.family: Fonts.sans
        font.pixelSize: providerBar.fontSize * 0.8
        focusPolicy: Qt.NoFocus
        onClicked: LauncherState.openProvider("providerlist");
    }

    Text {
        Layout.fillWidth: true
        text: LauncherState.activeProviderData.name
        color: Colours.text
        font.family: Fonts.sans
        font.pixelSize: providerBar.fontSize * 0.8
        elide: Text.ElideRight
    }


    Dropdown {
        id: dropdown
        model: LauncherState.activeProviderData?.actions?.dropdown
        visible: LauncherState.activeProviderData?.actions?.dropdown !== undefined
        Layout.preferredHeight: providerBar.fontSize * 1.5
        Layout.preferredWidth: 140
        focusPolicy: Qt.NoFocus
        leftPadding: 4

        valueRole: "action"
        currentValue: Elephant.providerStates.find(state => LauncherState?.activeProviderData?.actions?.dropdown?.map(a => a.action)?.includes(state)) ?? ""

        onActivated: {
            const context = { type: "dropdown", action: dropdown.currentValue, actionList: LauncherState?.activeProviderData?.actions?.dropdown?.map(a => a.action) ?? [] }
            LauncherState.providerAction(LauncherState.activeProviderId, context, dropdown.currentValue)
        }
    }

    Repeater {
        model: LauncherState.activeProviderData?.actions?.buttons
        visible: LauncherState.activeProviderData?.actions?.buttons !== undefined
        enabled: visible

        FlatButton {
            required property var modelData
            enabled: modelData?.enabled ?? true
            implicitHeight: mode === "icon" ? iconSize : (providerBar.fontSize * 1.6)
            implicitWidth: mode === "icon" ? iconSize : (contentItem.implicitWidth + (padding * 2))
            focusPolicy: Qt.NoFocus

            mode: modelData?.type || "text"
            text: modelData?.text ?? modelData?.action ?? "Button"
            iconName: modelData?.icon || "unknown"
            checked: modelData?.checked ?? false

            // I think this lil bit of hardcoding is fine
            icon.color: hovered ? (iconName === "actions/delete" ? Colours.aurora0 : Colours.snow2) : Colours.snow0
            iconSize: providerBar.fontSize * (modelData?.type === "checkbox" ? 1.2 : 1.6)

            onClicked: LauncherState.providerAction(LauncherState.activeProviderId, modelData, modelData?.action)
        }
    }
}
