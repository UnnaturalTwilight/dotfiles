// Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sinks: [...Pipewire.nodes.values].filter(n => n.isSink)

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function setDefaultSink(sink: PwNode) {
        if (sink) {
            Pipewire.preferredDefaultAudioSink = sink;
        }
    }

    readonly property bool ready: Pipewire.ready

    property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0

    onVolumeChanged: {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.volume = volume;
        }
    }

    property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    onMutedChanged: {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.muted = muted;
        }
    }

    readonly property string icon: {
        if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output.40")) {
            return "󰋋"; // JBL Tune 770NC
        } else if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output.88")) {
            // matches boath LE and normal mode at the risk of false positives
            return "󱡏"; // Skulcandy Sesh ANC Earbuds // bluez_output.88:08:94:A4:6B:25
        } else if (Pipewire.defaultAudioSink?.name == "alsa_output.pci-0000_00_1f.3.analog-stereo") {
            return "󰓃"; // Built in speakers or headphone jack
        } else {
            console.log("Unknown audio sink:", Pipewire.defaultAudioSink?.name ?? "null");
            return ""; // Fallback icon for unknown audio sink
        }
    }

    readonly property string name: Pipewire.defaultAudioSink?.name ?? "Unknown"
    readonly property string description: Pipewire.defaultAudioSink?.description ?? Pipewire.defaultAudioSink?.name ?? "Unknown"

    readonly property var extraProps: {
        var props = {
            "bluetooth": false,
            "iconDisplay": [80, -8],
            "data": {}
        };
        if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output")) {
            props.bluetooth = true;
            // These are dependent on the icon but happen to line up with bluetooth in my case
            props.iconDisplay = [96, -16];
        }
        // console.log(`ID: ${Pipewire.defaultAudioSink.id}`);
        if (ready && Pipewire.defaultAudioSink != null) {
            for (const [key, value] of Object.entries(Pipewire.defaultAudioSink?.properties)) {
                console.log(`${key}: ${value}`);
                props.data[key] = value;
            }
        }
        return props;
    }
}
