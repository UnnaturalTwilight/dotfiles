// Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property bool ready: Pipewire.ready

    readonly property real volume: {
        return Pipewire.defaultAudioSink?.audio?.volume ?? 0.0;
    }

    function setVolume(v) {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.volume = v;
        }
    }

    readonly property bool muted: {
        return Pipewire.defaultAudioSink?.audio?.muted ?? false;
    }

    function setMuted(m) {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.muted = m;
        }
    }

    readonly property var sinks: [...Pipewire.nodes.values].filter(n => n.isSink)

    readonly property string icon: {
        if (Pipewire.defaultAudioSink?.name == "bluez_output.40:72:18:AD:77:86") {
            return "󰋋"; // JBL Tune 770NC
        } else if (Pipewire.defaultAudioSink?.name == "bluez_output.88:08:94:A4:6B:25") {
            return "󱡏"; // Skulcandy Sesh ANC Earbuds
        } else if (Pipewire.defaultAudioSink?.name == "alsa_output.pci-0000_00_1f.3.analog-stereo") {
            return "󰓃"; // Built in speakers or headphone jack
        } else {
            console.log("Unknown audio sink:", Pipewire.defaultAudioSink?.name ?? "null");
            return ""; // Fallback icon for unknown audio sink
        }
    }

    readonly property string description: Pipewire.defaultAudioSink?.description ?? Pipewire.defaultAudioSink?.name ?? "Unknown"

    readonly property list<int> styles: {
        if (Pipewire.defaultAudioSink?.name == "bluez_output.40:72:18:AD:77:86") {
            return [96, -16];
        } else if (Pipewire.defaultAudioSink?.name == "bluez_output.88:08:94:A4:6B:25") {
            return [96, -16];
        } else if (Pipewire.defaultAudioSink?.name == "alsa_output.pci-0000_00_1f.3.analog-stereo") {
            return [80, -8];
        } else {
            return [80, -8];
        }
    }
}
