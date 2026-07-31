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
        console.log("Switched audio sink to:", sink.name);
        if (sink) {
            Pipewire.preferredDefaultAudioSink = sink;
        }
    }

    readonly property bool ready: Pipewire.ready

    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0

    function setVolume(volume) {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.volume = volume;
        }
    }

    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    function toggleMute() {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }

    function setMuted(muted) {
        if (Pipewire.defaultAudioSink) {
            Pipewire.defaultAudioSink.audio.muted = muted;
        }
    }

    readonly property string icon: {
        if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output.8C")) {
            return "devices/headphones"; // Skulcandy HESH 540 ANC Headphones
        } else if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output.88")) {
            // matches boath LE and normal mode at the risk of false positives
            return "devices/earbuds"; // Skulcandy Sesh ANC Earbuds
        } else if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output.D4")) {
            return "devices/earbuds";
        } else if (Pipewire.defaultAudioSink?.name == "alsa_output.pci-0000_00_1f.3.analog-stereo") {
            return "devices/speaker"; // Built in speakers or headphone jack
        } else {
            console.log("Unknown audio sink:", Pipewire.defaultAudioSink?.name ?? "null");
            return "unknown"; // Fallback icon for unknown audio sink
        }
    }

    readonly property string name: Pipewire.defaultAudioSink?.name ?? "Unknown"
    readonly property string description: Pipewire.defaultAudioSink?.description ?? Pipewire.defaultAudioSink?.name ?? "Unknown"

    readonly property var extraProps: {
        var props = {
            "bluetooth": false,
            "iconDisplaySize": 80,
            "batteryLevel": null,
            "batteryIcon": null,
            "data": {}
        };
        // console.log(`ID: ${Pipewire.defaultAudioSink.id}`);
        if (ready && Pipewire.defaultAudioSink != null) {
            for (const [key, value] of Object.entries(Pipewire.defaultAudioSink?.properties)) {
                // console.log(`${key}: ${value}`);
                props.data[key] = value;
            }
        }
        if (Pipewire.defaultAudioSink?.name.startsWith("bluez_output")) {
            props.bluetooth = true;
            // These are dependent on the icon but happen to line up with bluetooth in my case
            props.iconDisplaySize = 70;
            if (props.data["api.bluez5.address"]) {
                props.batteryLevel = Bluetooth.batteryLevelByMAC(props.data["api.bluez5.address"]);
                props.batteryIcon = Battery.icons[Math.round(10 - (props.batteryLevel * 10))];
            }
        }
        return props;
    }
}
