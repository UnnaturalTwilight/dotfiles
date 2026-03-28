// quickshell/niri-backdrop/shell.qml
import Quickshell
import Quickshell.Io
import QtQuick

import qs.backdrop
import qs.panel
import qs.auth
import qs.utils

Scope {
    id: root

    Variants {

        model: Quickshell.screens
        Backdrop {}
    }

    // Variants {

    //     model: Quickshell.screens
    //     Debug {}
    // }

    // LazyLoader {
    //     id: panelLoader
    //     component: 
    //     loading: true
    // }
    
    Start {
        id: startPanel
        screen: System.primaryScreen
    }

    Polkit {}

    IpcHandler {
        target: "start"

        function toggle(): void {
            startPanel.toggle();
        }
        function show(): void {
            startPanel.show();
        }
        function hide(): void {
            startPanel.hide();
        }
        function shown(): bool {
            return startPanel.shown();
        }
    }

    IpcHandler {
        target: "idle"

        function inhibit(inhibited: bool): void {
            Idle.enabled = !inhibited;
        }
        function respectInhibitors(enabled: bool): void {
            Idle.respectInhibitors = enabled;
        }
        function inhibited(): bool {
            return !Idle.enabled;
        }
    }

    Component.onCompleted: {
        Idle.enabled = true;
    }
}
