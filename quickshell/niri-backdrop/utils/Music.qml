// Music.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    readonly property var players: [...Mpris.players.values]

    readonly property var mpd: [...Mpris.players.values].find(s => s.identity === "MPD")

    readonly property var title: mpd?.trackTitle || "Unknown Track"
    readonly property var artist: mpd?.trackArtist || "Unknown Artist"
    readonly property var album: mpd?.trackAlbum || "Unknown Album"
    readonly property var position: mpd?.position
    readonly property var length: mpd?.length
    readonly property var albumArt: mpd?.trackArtUrl

    readonly property bool playing: mpd?.playbackState === MprisPlaybackState.Playing

    readonly property real progress: mpd ? (mpd.position / mpd.length) : 0
}
