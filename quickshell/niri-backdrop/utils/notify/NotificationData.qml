// NotificationData.qml

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: root

    // The actual notification this data is for
    property Notification notification

    property int id
    property string appName
    property string appIcon
    property string summary
    property string body
    property string image
    property var urgency
    property real expireTimeout
    property bool temporary // transient is a reserved word
    property string desktopEntry
    property var hints

    // Actions & Inline replies
    property bool resident
    property list<var> actions
    property bool hasActionIcons
    property bool hasInlineReply
    property string inlineReplyPlaceholder

    // Custom properties
    property bool onscreen: true
    property date timestamp: new Date()

    readonly property Timer timer: Timer {
        running: root.expireTimeout > 0
        interval: root.expireTimeout
        onTriggered: {
            root.expire();
        }
    }

    function close(): void {
        if (Notify.list.includes(this)) {
            Notify.list = Notify.list.filter(n => n !== this);
            notification?.dismiss();
            destroy();
        }
    }

    function expire(): void {
        if (Notify.list.includes(this) && root.temporary) {
            Notify.list = Notify.list.filter(n => n !== this);
            notification?.expire();
            destroy();
        } else {
            root.onscreen = false;
        }
    }

    readonly property Connections conn: Connections {
        function onClosed(reason): void {
            if (reason === NotificationCloseReason.Expired) {
                root.expire();
            } else {
                root.close();
            }
            // console.log("Notification closed:", root.id, "Reason:", NotificationCloseReason.toString(reason));
        }

        function onSummaryChanged(): void {
            root.summary = root.notification.summary;
        }

        function onBodyChanged(): void {
            root.body = root.notification.body;
        }

        function onAppIconChanged(): void {
            root.appIcon = root.notification.appIcon;
        }

        function onAppNameChanged(): void {
            root.appName = root.notification.appName;
        }

        function onImageChanged(): void {
            root.image = root.notification.image;
        }

        function onExpireTimeoutChanged(): void {
            root.expireTimeout = root.notification.expireTimeout;
        }

        function onUrgencyChanged(): void {
            root.urgency = root.notification.urgency;
        }

        function onResidentChanged(): void {
            root.resident = root.notification.resident;
        }

        function onHasActionIconsChanged(): void {
            root.hasActionIcons = root.notification.hasActionIcons;
        }

        function onActionsChanged(): void {
            root.actions = root.notification.actions.map(a => ({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            }));
        }

        function onHintsChanged(): void {
            root.hints = root.notification.hints;
        }

        target: root.notification
    }

    Component.onCompleted: {
        if (!notification) {
            return;
        }

        id = notification.id;
        summary = notification.summary;
        body = notification.body;
        appIcon = notification.appIcon;
        appName = notification.appName;
        image = notification.image;
        expireTimeout = notification.expireTimeout;
        hints = notification.hints;
        urgency = notification.urgency;
        resident = notification.resident;
        temporary = notification.transient;
        hasActionIcons = notification.hasActionIcons;
        actions = notification.actions.map(a => ({
            identifier: a.identifier,
            text: a.text,
            invoke: () => a.invoke()
        }));
    }
}
