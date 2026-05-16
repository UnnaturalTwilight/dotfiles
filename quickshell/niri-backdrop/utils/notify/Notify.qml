// Notify.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property list<NotificationData> list: []

    property alias onscreen: onscreenModel.values
    property alias doNotDisturb: props.doNotDisturb

    property alias tracked: notifServer.trackedNotifications

    ScriptModel {
        id: onscreenModel
        values: root.list.filter(notif => notif.onscreen)
    }

    PersistentProperties {
        id: props
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
                onscreen: !props.doNotDisturb,
                notification: notif
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
    }

    Component {
        id: notifComp
        NotificationData {}
    }
}
