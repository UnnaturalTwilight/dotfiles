// NotificationData.qml

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

import "rewrites.js" as Rewrites

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
    property string category: hints?.category || "default"
    property bool hasProgress: hints?.value !== undefined
    property real progress: hints?.value / 100

    readonly property Timer timer: Timer {
        running: root.expireTimeout > 0 && root.urgency !== NotificationUrgency.Critical
        interval: root.expireTimeout
        onTriggered: {
            root.expire();
        }
    }

    function defaultAction(): void {
        const defaultAction = Rewrites.getDefaultAction(root.actions, root);
        if (defaultAction) {
            defaultAction?.invoke();
        } else {
            root.dismiss();
        }
    }

    function close(): void {
        if (Notify.list.includes(this)) {
            Notify.list = Notify.list.filter(n => n !== this);
            notification?.dismiss();
        }
    }

    function dismiss(): void {
        if (root.temporary) {
            close();
        }
        root.onscreen = false;
    }

    function expire(): void {
        if (Notify.list.includes(this) && root.temporary) {
            Notify.list = Notify.list.filter(n => n !== this);
            notification?.expire();
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

        function onAppNameChanged(): void { root.appName = root.notification.appName; }
        function onAppIconChanged(): void { root.appIcon = root.notification.appIcon; }
        function onSummaryChanged(): void { root.summary = Rewrites.rewriteSummary(root.notification.summary, root.notification); }
        function onBodyChanged(): void { root.body = Rewrites.rewriteBody(root.notification.body, root.notification); }
        function onImageChanged(): void { root.image = Rewrites.rewriteImage(root.notification.image, root.notification); }
        function onUrgencyChanged(): void { root.urgency = root.notification.urgency; }
        function onExpireTimeoutChanged(): void { root.expireTimeout = root.notification.expireTimeout; }
        function onDesktopEntryChanged(): void { root.desktopEntry = root.notification.desktopEntry; }
        function onHintsChanged(): void { root.hints = root.notification.hints; }
        function onResidentChanged(): void { root.resident = root.notification.resident; }
        function onHasActionIconsChanged(): void { root.hasActionIcons = root.notification.hasActionIcons; }
        function onHasInlineReplyChanged(): void { root.hasInlineReply = root.notification.hasInlineReply; }
        function onInlineReplyPlaceholderChanged(): void { root.inlineReplyPlaceholder = root.notification.inlineReplyPlaceholder; }

        function onActionsChanged(): void {
            root.actions = root.notification.actions.map(a => ({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            }));
        }

        target: root.notification
    }

    Component.onCompleted: {
        // console.log("New notification:", root.id);
        // console.log("Hints: ", JSON.stringify(root.hints));

        // Use the kde hint if it exists
        if (root.hints?.["x-kde-reply-placeholder-text"] !== undefined) {
            root.inlineReplyPlaceholder = root.hints["x-kde-reply-placeholder-text"];
        }
    }
}
