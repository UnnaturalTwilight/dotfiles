// Polkit.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Polkit
import QtQuick

Scope {
    id: root

    readonly property alias agent: agent

    function init(): void {}

    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            promptLoader.active = true;
        }
    }

    Connections {
        target: agent.flow

        function onAuthenticationSucceeded(): void {
            Qt.callLater(() => {
                promptLoader.active = false;
            });
        }

        function onAuthenticationRequestCancelled(): void {
            Qt.callLater(() => {
                promptLoader.active = false;
            });
        }
    }

    LazyLoader {
        id: promptLoader
        loading: false

        component: PolkitPrompt {
            agent: agent
        }
    }
}
