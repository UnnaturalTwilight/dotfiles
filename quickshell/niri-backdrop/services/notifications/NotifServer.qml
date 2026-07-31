// NotifServer.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property list<NotifData> list: []
    property alias tracked: server.trackedNotifications

    property alias doNotDisturb: props.doNotDisturb

    PersistentProperties {
        id: props
        reloadableId: "Notify"

        property bool doNotDisturb: false
    }

    NotificationServer {
        id: server

        bodyHyperlinksSupported: false
        bodyMarkupSupported: true
        inlineReplySupported: true
        keepOnReload: true
        persistenceSupported: true
        actionsSupported: true
        bodySupported: true
        bodyImagesSupported: false
        imageSupported: true
        actionIconsSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const comp = notifComp.createObject(root, {
                notification: notif,
                id: notif.id,
                onscreen: (!props.doNotDisturb && !notif.lastGeneration) || notif.urgency === NotificationUrgency.Critical,
                expireTimeout: notif.expireTimeout === -1 ? 10000 : notif.expireTimeout
            });

            console.log("Notification received:");
            root.logNotif(notif);

            root.list = [comp, ...root.list];
        }
    }

    function clearAll(): void {
        while (root.list.length > 0) {
            for (const notif of root.list) {
                notif.close();
            }
        }
    }

    function logNotif(notif): void {
        console.log("ID:", notif.id);
        console.log("App Name:", notif.appName);
        console.log("Summary:", notif.summary);
        console.log("Body:", notif.body);
        console.log("Urgency:", NotificationUrgency.toString(notif.urgency));
        console.log("App Icon:", notif.appIcon);
        console.log("Image:", notif.image);
        console.log("Actions:", JSON.stringify(notif.actions));
        console.log("Hints:", JSON.stringify(notif.hints));
        console.log("---");
    }

    IpcHandler {
        id: notifIPC
        target: "notifs"

        function clear(): void {
            root.clearAll();
        }

        function toggleDnd(): void {
            props.doNotDisturb = !props.doNotDisturb;
        }

        function setDnd(enabled: bool): void {
            props.doNotDisturb = enabled;
        }

        function getDnd(): bool {
            return props.doNotDisturb;
        }

        function getCount(): int {
            return root.list.length;
        }

        function dump(): void {
            console.log("\nNotification dump:");
            for (const notif of root.list) {
                root.logNotif(notif);
            }
        }
    }

    Component {
        id: notifComp
        NotifData {}
    }
}
