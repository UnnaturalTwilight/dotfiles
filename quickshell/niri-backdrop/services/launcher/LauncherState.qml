// LauncherState.qml
pragma Singleton

import Quickshell
import QtQuick

import qs.services
import qs.services.launcher

Singleton {
    id: state

    property bool open: false
    property ShellScreen screen: System.focusedScreen
    property bool followMouse: false

    // FIXME: Better naming
    property var view: null

    property string activeProviderId: "global"
    readonly property var activeProviderData: Providers.data?.[activeProviderId]
    property string cachedPrefix: ""
    property bool prefixActive: false
    property bool working: false
    property string searchTerm: ""
    property string errorMessage: ""

    property bool debugRendering: System.debugMode

    property ListModel results: ListModel {}

    onOpenChanged: { if (!open) { resetState(); } }

    function resetState() {
        state.results.clear();
        state.activeProviderId = "global";
        view.input.text = "";
        state.searchTerm = "";
        state.cachedPrefix = "";
        state.prefixActive = false;
        state.errorMessage = "";
        state.working = false;
    }

    function closeWindow() {
        if (state.view) { state.view.closeAnim.start(); }
        else { state.open = false; }
    }

    function openWindow() {
        if (!state.view) {
            console.error("[Launcher] view is null");
            // TODO: popup an error message
            state.open = false;
            return;
        }

        state.screen = System.focusedScreen;
        state.open = true
    }

    function toggle(providerId) {
        if (!state.followMouse && (state.screen !== System.focusedScreen)) {
            state.screen = System.focusedScreen;
            // refresh the state while preserving input if the provider is already active
            const clear = !(providerId === state.activeProviderId || providerId === undefined);
            openProvider((providerId ?? state.activeProviderId), clear);
        } else if (state.open && (providerId === state.activeProviderId || providerId === undefined)) {
            closeWindow();
        } else {
            openProvider(providerId);
        }
    }

    function openProvider(providerId = "global", clear = true) {
        if (!state.open) { openWindow(); }
        state.working = true;
        state.activeProviderId = providerId;
        state.cachedPrefix = "";
        state.prefixActive = false;
        state.errorMessage = "";
        if (clear) {
            // Clear input and force the results to refresh
            view.input.text = "";
            refreshResults();
        } else {
            // re-run prefix resolution and refresh results
            search(view.input.text);
        }
    }

    function search(query) {
        const resolved = Providers.resolvePrefix(state.activeProviderId, state.cachedPrefix, state.prefixActive, query);
        // DOCS: resolved = { provider: "STRING", prefix: "STRING", active: BOOLEAN, query: "STRING" }
        state.activeProviderId = resolved.provider;
        state.cachedPrefix = resolved.prefix;
        state.prefixActive = resolved.active;
        state.searchTerm = resolved.query;
        refreshResults();
    }

    function back() {
        // FIXME: Real implementation
        if (activeProviderId === "providerlist") {
            state.activeProviderId = "global";
        } else {
            state.activeProviderId = "providerlist";
        }
        search("");
    }

    // TODO: implement preserveSelection -- or not idk it is that needed
    function refreshResults() {
        const entries = Providers.query(state.activeProviderId, state.searchTerm);
        if (entries === null) { return; }

        // Refresh synchronous entries
        state.results.clear();
        entries.forEach((entry) => { state.results.append(entry); });

        // Append fallback result to synchronous entries if available
        let fallback = Providers.queryFallback(state.activeProviderId, state.searchTerm, null);
        if (fallback !== null) { state.results.append(fallback); }

        state.working = false;
    }

    function activate(idx, context, action) {
        const entry = state.results.get(idx);
        if (!entry?.actions) { return; }

        if (context?.type === "keyboard") {
            if (context.ctrl && entry.actions?.ctrl !== undefined) {
                action = entry.actions.ctrl;
            } else if (context.alt && entry.actions?.alt !== undefined) {
                action = entry.actions.alt;
            } else if (context.shift && entry.actions?.shift !== undefined) {
                action = entry.actions.shift;
            } //... I can't be bothered exhaustively list the possible combos
        }
        if (action === undefined) { action = entry.actions?.default; }

        // DOCS: What is the full data structure of returnValue?
        const returnValue = Providers.activate(state.activeProviderId, entry, action, state.searchTerm);

        if (returnValue === null) {
            // Activation was a no-op, nothing to do
            state.working = false;
            return;
        }

        if (returnValue?.errorMessage) {
            state.errorMessage = returnValue.errorMessage;
            state.working = false;
        }

        if (returnValue?.update) {
            state.results.set(idx, returnValue.update);
        } else if (returnValue?.refresh) {
            Qt.callLater(refreshResults);
        } else if (returnValue?.reset) {
            resetState();
        } else if (returnValue?.close ?? true) {
            closeWindow();
        }
    }

    function providerAction(provider, context, action) {

        const returnValue = Providers.providerAction(provider, context, action, state.searchTerm);

        if (returnValue === null) {
            state.working = false;
        } else if (returnValue?.errorMessage) {
            state.errorMessage = returnValue.errorMessage;
            state.working = false;
        } else if (returnValue?.update) {
            // TODO!
            state.working = false;
        } else if (returnValue?.refresh) {
            Qt.callLater(refreshResults);
        } else if (returnValue?.close ?? false) {
            closeWindow();
        }
    }

    function autocomplete(idx, context) {
        const entry = state.results.get(idx);
        if (!entry) { return; }

        const newText = Providers.autocomplete(state.activeProviderId, entry, state.searchTerm, context);
        if (newText === null) { return; }
        if (state.activeProviderData?.impl?.prefixes !== "local") {
            const prefix = state.cachedPrefix;
            state.view.input.text = prefix + newText;
        } else {
            state.view.input.text = newText;
        }
    }
}
