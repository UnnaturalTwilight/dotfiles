// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm") ?? (() => {
        console.error("[Time] Formated time was undefined " + clock.date);
        return "99:99";
    })();

    readonly property string date: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy");

    readonly property string isoDate: Qt.formatDateTime(clock.date, "yyyy-MM-dd");

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
