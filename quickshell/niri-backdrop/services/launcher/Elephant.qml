// Elephant.qml
// Based on: https://github.com/Afillated/quickshell-carbonflake/blob/main/panels/Launcher.qml
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs.services
import qs.services.launcher

Singleton {
    id: elephant

    property bool bridgeReady: false
    property var pending: []
    property var providerStates: []
    property var providerActions: []
    property int requestSerial: 0
    property int queryId: 0
    property int stateId: 0
    property int activationId: 0
    property int activationQueryId: 0
    property string activationPolicy: "close"
    property bool activationUpdated: false
    property int maxRequestedEntries: 30

    property int desyncId: -1

    property var excludeLogging: ["item"]

    Connections {
        target: LauncherState

        function onOpenChanged() {
            if (LauncherState.open) {

            } else {
                elephant.bridgeReady = false;
                elephant.reset()
            }
        }

        function onViewChanged() {
            if (!LauncherState.view) {
                elephant.bridgeReady = false;
            }
        }
    }

    // CLEANUP: Should I insted refrence Providers' instance of this
    Component {
        id: entryComp
        EntryData {}
    }

    property Process bridge: Process {
        // The Python side of this is purely vibecoded and I have no intention to change that for V2 of the launcher
        command: [Quickshell.shellDir + "/services/launcher/elephant-bridge.py"]
        running: LauncherState.open && LauncherState.view !== null
        stdinEnabled: true

        onStarted: {
            elephant.bridgeReady = true;
            resetProviderStates();
            LauncherState.refreshResults();
        }

        onExited: {
            elephant.bridgeReady = false;
            elephant.reset();
        }

        stdout: SplitParser {
            onRead: line => elephant.handleMessage(JSON.parse(line))
        }
    }

    function reset() {
        elephant.queryId = ++requestSerial;
        elephant.stateId = ++requestSerial;
        elephant.activationId = ++requestSerial;
        elephant.providerStates = [];
        elephant.providerActions = [];
        elephant.activationQueryId = 0;
        elephant.activationPolicy = "close";
        elephant.activationUpdated = false;
        elephant.desyncId = -1;
        LauncherState.working = false;
    }

    function resetProviderStates() {
        // Some providers have persistant states that should get reset
        // TODO: define this in Providers.data
        let msg = "";
        elephant.activationId = ++requestSerial;
        msg += JSON.stringify({
            op: "activate",
            id: elephant.activationId,
            provider: "clipboard",
            identifier: "",
            action: "show_combined",
            query: "",
            wait: false
        }) + "\n"
        bridge.write(msg);
    }

    function handleMessage(msg) {
        if (System.debugMode && !elephant.excludeLogging.includes(msg.type)) { console.log("[Elephant][msg]", JSON.stringify(msg)); }
        if (!LauncherState.open) { return; }

        if (msg.type === "error") {
            if (msg.id === elephant.activationId) {
                // activation error
                LauncherState.working = false;
                if (elephant.activationQueryId !== elephant.queryId) { return; }
                requestProviderState(LauncherState.activeProviderId);
            }
            if (msg.id === elephant.queryId || msg.id === elephant.stateId || msg.id === elephant.activationId) {
                console.warn("[Elephant]", msg.message);
                // Ignore errors if a non-elephant provider is active
                // FIXME: This will cause errors to not be reported on the 'global' provider despite it using elephant results
                if (LauncherState.activeProviderData?.impl?.type !== "elephant") { return; }
                // general error
                LauncherState.errorMessage = "Elephant: " + msg.message;
            }
            return;
        }

        if (msg.type === "state") {
            if (msg.id === stateId && msg.provider === LauncherState.activeProviderId) {
                elephant.providerStates = msg.states ?? [];
                elephant.providerActions = msg.actions ?? [];
            }
            return;
        }

        if (msg.type === "activated") {
            if (msg.id === elephant.activationId) {
                LauncherState.working = false;
                if (elephant.activationQueryId === elephant.queryId) {
                    if (elephant.activationPolicy === "reload" || !elephant.activationUpdated) {
                        LauncherState.refreshResults();
                    } else {
                        requestProviderState(LauncherState.activeProviderId);
                    }
                }
            }
            return;
        }

        if (msg.type === "item" && msg.op === "activate") {
            if (msg.id === elephant.activationId && elephant.activationQueryId === elephant.queryId) {
                elephant.activationUpdated = updateResults(msg.item) || elephant.activationUpdated;
            }
            return;
        }

        if (msg.id !== elephant.queryId || msg.query !== LauncherState.searchTerm) {
            if (System.debugMode && msg.id !== elephant.desyncId) {
                console.warn(`[Elephant] Desync Detected between query ${elephant.queryId} and message ${msg.id}`);
            }
            elephant.desyncId = msg.id;
            return;
        }

        if (msg.type === "item") {
            // FIXME: bluetooth sends double entries sometimes
            pending.push(msg.item);
        } else if (msg.type === "done") {
            showResults();
            requestProviderState(LauncherState.activeProviderId);
        }
    }

    function query(provider, query) {
        if (!elephant.bridgeReady) {
            LauncherState.working = true;
            return null;
        }

        elephant.queryId = ++requestSerial;
        bridge.write(JSON.stringify({
            op: "query",
            id: elephant.queryId,
            // This is to facilitate passing an array of provider ids or a single provider id
            providers: typeof provider === "string" ? [provider] : provider,
            query: query,
            max: elephant.maxRequestedEntries
        }) + "\n");
        return null; // Indicates that the query is asynchronous
    }

    // provider: The id of the provider backing the activated entry
    // entry: The full entry object
    // action: The activated action to perform on the entry
    // query: The current search query, if any
    function activate(provider, entry, action, query) {
        if (!elephant.bridgeReady || !action) { return null; }
        // Split this off because I'm less confident it's needed
        if (LauncherState.working) {
            console.warn("[Elephant][activate] Blocked activation due to working state");
            return null;
        }
        elephant.activationId = ++requestSerial;
        elephant.activationQueryId = elephant.queryId;

        // TODO: base on provider definitions
        if (
            (entry === null) || (provider === "bluetooth") ||
            (provider === "calc" && ["save", "delete", "delete_all"].includes(action)) ||
            (provider === "clipboard" && ["remove_all", "show_combined", "show_images_only", "show_text_only", "show_pinned_only", "pause", "unpause", "remove", "pin", "unpin"].includes(action))
        ) {
            elephant.activationPolicy = "reload";
        } else if (provider === "playerctl") {
            elephant.activationPolicy = "update";
        } else {
            elephant.activationPolicy = "close";
        }

        elephant.activationUpdated = false;
        LauncherState.errorMessage = "";
        LauncherState.working = elephant.activationPolicy !== "close";
        if (elephant.activationPolicy !== "close") {
            elephant.stateId = ++requestSerial;
            elephant.providerActions = [];
        }

        bridge.write(JSON.stringify({
            op: "activate",
            id: elephant.activationId,
            provider: provider,
            identifier: entry?.identifier ?? "",
            action: action,
            query: query,
            wait: LauncherState.working
        }) + "\n");

        switch (elephant.activationPolicy) {
            case "update":
                // TODO!
            case "reload":
                return { close: false, refresh: true };
            case "close":
            default:
                return { close: true };
        }
    }

    function providerAction(provider, context, action, query) {
        return activate(provider, null, action, query);
    }

    function requestProviderState(provider) {
        if (!elephant.bridgeReady || !provider || LauncherState.working) { return; }

        elephant.stateId = ++requestSerial;
        elephant.providerActions = [];
        elephant.providerStates = [];

        bridge.write(JSON.stringify({
            op: "state",
            id: elephant.stateId,
            provider: provider
        }) + "\n");
    }

    function updateResults(item) {}

    // CLEANUP: better name, this function handles updating the results list after
    // all the entries have been received from elephant
    // the name should make it clear that it commits the async query results to the UI
    function showResults() {
        // Sort the pending results by score (descending)
        pending.sort((a, b) => (b.score ?? 0) - (a.score ?? 0));

        // Clear the current results
        LauncherState.results.clear();

        // Push the pending results to the results list
        for (const item of pending) {
            LauncherState.results.append(resultEntry(item));
        }

        // Query the fallback provider, if one is available, and append the result to the results list
        let fallback = Providers.queryFallback(LauncherState.activeProviderId, LauncherState.searchTerm, null);
        if (fallback !== null) {
            LauncherState.results.append(fallback);
        }

        pending = [];
        LauncherState.working = false;
    }

    // Converts an item from elephant's result format to a EntryData object
    function resultEntry(item) {
        // REVIEW: should these objects have a parent set?
        let entry = entryComp.createObject(null, {
            identifier: item.identifier,
            provider: item.provider,
            text: item?.text ?? "",
            subtext: item?.subtext ?? "",
            icon: item?.icon ?? "",
            type: "item",
            active: true,
            hints: {
                score: item?.score,
                state: item?.state,
                preview: item?.preview,
                preview_type: item?.preview_type,
                fuzzyinfo: item?.fuzzyinfo,
            },
            actions: {
                default: "",
                list: item?.actions,
            },
        });

        // Provider specific conversion handling
        // Some of this can bound to provider definitions,
        // but some things are just so random that it wouldn't make sense.
        // Perhaps something like impl.postProcessFn(item) => (EntryData {}) is the way to go
        // That would still entail a whole js file to define the functions for each provider but IDK

        // qmllint disable
        // every single assignment in here throws a warning
        if (item.provider === "calc") {
            entry.icon = "";
            entry.actions.default = "copy";
            entry.actions.ctrl = "save";
            entry.hints.monospace = true;

            // Add actions as buttons
            entry.actions.buttons = { column: [] };
            if (item.actions.includes("edit")) { entry.actions.buttons.column.push({ type: "icon", icon: "actions/edit", action: "edit" }); }
            if (item.actions.includes("delete")) { entry.actions.buttons.column.push({ type: "icon", icon: "actions/delete", action: "delete" }); }

        } else if (item.provider === "clipboard") {
            entry.icon = "";
            entry.actions.default = "copy";
            entry.hints.maxLines = 5;
            entry.hints.textWrap = true;
            entry.hints.autoHeight = true;

            if (item?.preview_type === "file" && item?.preview.endsWith(".png")) {
                entry.hints.preview_type = "image";
            }

            // Add actions as buttons
            entry.actions.buttons = { column: [] };
            // if (item.actions.includes("pin")) { entry.actions.buttons.column.push({ type: "icon", icon: "states/pin", action: "pin" }); }
            if (item.actions.includes("edit")) { entry.actions.buttons.column.push({ type: "icon", icon: "actions/edit", action: "edit" }); }
            if (item.actions.includes("remove")) { entry.actions.buttons.column.push({ type: "icon", icon: "actions/delete", action: "remove" }); }

        } else if (item.provider === "bluetooth") {
            if (item?.state.includes("disconnected")) {
                entry.actions.default = "connect";
                entry.active = false;
            } else if (item?.state.includes("connected")) {
                entry.actions.default = "disconnect";
            }

            // Add actions as buttons
            entry.actions.buttons = { row: [] };
            for (const action of Array.from(new Set(item.actions)).reverse()) {
                entry.actions.buttons.row.push({ type: "text", text: action, action: action });
            }

        } else if (item.provider === "desktopapplications") {
            entry.actions.default = "start";
            entry.actions.ctrl = "new_instance";
        } else if (item.provider === "playerctl") {
            entry.type = "media-player";
            // WHYYYYY? I can't believe that parsing the icon is the best way to do this
            const paused = item.icon === "media-playback-start";
            entry.hints.state = paused ? ["paused"] : ["playing"];
            entry.actions.default = paused ? "play" : "pause";
            entry.actions.ctrl = "next"; // TODO: Non-enter bind
            entry.actions.alt = "prev"; // TODO: Non-enter bind
            // This is even worse than parsing the icon IMO
            // At least it's a char that isn't likely to appear in the fields
            // TODO: Guard against `·` showing up in the artist/album field
            const info = item.subtext.split(" · ");
            entry.hints.media = { player: info[0], artist: info[1], volume: info[2] };

            // Make the subtext look a little nicer
            entry.subtext = `${info[1]}  ·  ${info[0]}  ·  󱄠 ${info[2]}%`;

            // Action button definitions
            entry.actions.buttons = {
                icon: { type: "icon", icon: paused ? "actions/play" : "actions/pause", action: paused ? "play" : "pause" },
                row: [
                    { type: "icon", large: true, icon: "actions/previous", action: "prev" },
                    { type: "icon", large: true, icon: "actions/next", action: "next" },
                ]
            }
        }
        // qmllint enable

        return entry;
    }
}
