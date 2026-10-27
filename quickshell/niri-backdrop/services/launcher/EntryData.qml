// EntryData.qml
/// Type definition for launcher entries

import QtQuick

QtObject {
    // unique identifier for the entry
    required property string identifier

    // Id of the provider that owns this entry
    required property string provider // DOCS: special values?

    // text to display for the entry
    required property string text

    // text to display as a subtitle for the entry
    property string subtext: ""

    // icon to display for the entry
    property string icon: ""

    // Type of the entry
    property string type: "item"

    // Misc hints for the entry
    // DOCS: what hints?
    property var hints: ({})

    // Actions associated with the entry
    property var actions: ({ default: "activate" })

    // TODO: Activate function?
}
