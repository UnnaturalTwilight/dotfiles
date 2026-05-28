// Notify.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

import "rewrites.js" as Rewrites

Singleton {
    id: root

    property list<NotificationData> list: []
    property alias tracked: notifServer.trackedNotifications

    property alias doNotDisturb: props.doNotDisturb

    PersistentProperties {
        id: props
        reloadableId: "Notify"

        property bool doNotDisturb: false
    }

    NotificationServer {
        id: notifServer

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
            for (const notif of root.list) {
                Rewrites.dumpNotif(notif);
            }
        }
    }

    Component {
        id: notifComp
        NotificationData {}
    }
}
