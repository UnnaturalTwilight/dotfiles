// Providers.qml
pragma Singleton

import Quickshell
import QtQuick

import qs.services
import qs.services.launcher
// qs.services.niri is needed so that js providers can access niri services
import qs.services.niri // qmllint disable unused-imports

import "runner.js" as RunnerImpl
import "menus.js" as MenusImpl
import "websearch.js" as WebsearchImpl
import "windows.js" as WindowsImpl

Singleton {
    id: providers

    /// Provider Data Object
    // See ./README.md for explanation of data structure

    // TODO: concat multiple of these definitions so that the provider definitions can live with their Implementations

    readonly property var data: ({
        global: {
            id: "global",
            name: "Search",
            prompt: "Search…",
            icon: "search",
            svg: "symbols/search",
            show: false,
            impl: {
                type: "global",
                search: ["desktopapplications"],
                submenus: ["bluetooth", "network", "power", "system", "quickshell", "providerlist"],
                fallback: "websearch",
                prefixes: "global"
            },
        },
        providerlist: {
            id: "providerlist",
            name: "Providers",
            icon: "applications-other",
            svg: "symbols/view-list",
            prefix: ";",
            show: false,
            impl: {
                type: "providerlist",
                prefixes: "global"
            }
        },

        // Elephant providers
        desktopapplications: {
            id: "desktopapplications",
            name: "Desktop Applications",
            prompt: "Search Apps…",
            icon: "Appstore",
            svg: "symbols/apps",
            keywords: ["apps"],
            prefix: " ",
            show: true,
            impl: {
                type: "elephant",
            }
        },
        bluetooth: {
            id: "bluetooth",
            name: "Bluetooth Devices",
            icon: "bluetooth",
            svg: "network/bluetooth",
            keywords: ["bt"],
            show: true,
            impl: {
                type: "elephant",
            },
            actions: {
                buttons: [
                    { type: "text", text: "Scan for nearby devices", action: "find" },
                ],
            },
        },
        calc: {
            id: "calc",
            name: "Calculator",
            icon: "accessories-calculator",
            svg: "symbols/math-function",
            prefix: "=",
            keywords: ["qalc"],
            show: true,
            impl: {
                type: "elephant",
                autocompleteFn: (provider, entry, query, context) => {
                    if (context.ctrl) { return entry.subtext; }
                    if (context.shift) { return entry.text; }
                    return entry.hints?.state[0] === "current" ? entry.text : entry.subtext;
                },
            },
            actions: {
                buttons: [
                    { action: "delete_all", text: "Clear History", icon: "actions/delete", type: "both", destructive: true },
                ],
            },
        },
        clipboard: {
            id: "clipboard",
            name: "Clipboard",
            icon: "timeshift",
            svg: "symbols/clipboard",
            prefix: ":",
            keywords: [],
            show: true,
            impl: {
                type: "elephant",
            },
            actions: {
                buttons: [
                    { action: "remove_all", text: "Clear History", icon: "actions/delete", type: "both", destructive: true },
                ],
                dropdown: [
                    { action: "show_combined", text: "Show All" },
                    { action: "show_text_only", text: "Text Only" },
                    { action: "show_images_only", text: "Images Only" },
                    { action: "show_pinned_only", text: "Pinned Only" },
                ],
            },
        },
        playerctl: {
            id: "playerctl",
            name: "Playing Media",
            icon: "media-player",
            svg: "symbols/music",
            prefix: "<",
            keywords: ["mpd", "music", "mpris", "playerctl"],
            show: true,
            impl: {
                type: "elephant",
            },
        },

        // JS providers
        runner: {
            id: "runner",
            name: "Runner",
            icon: "terminal",
            svg: "symbols/terminal",
            prefix: ">",
            keywords: ["shell"],
            show: true,
            impl: {
                type: "js",
                queryFn: RunnerImpl.query,
                activateFn: RunnerImpl.activate,
            },
        },
        websearch: {
            id: "websearch",
            name: "Web Search",
            icon: "applications-internet",
            svg: "network/web",
            prefix: "@",
            keywords: ["google"],
            show: true,
            impl: {
                type: "js",
                queryFn: WebsearchImpl.query,
                activateFn: WebsearchImpl.activate,
                fallbackFn: WebsearchImpl.fallback,
                autocompleteFn: WebsearchImpl.autocomplete,
                prefixes: "local",
            },
        },
        windows: {
            id: "windows",
            name: "Windows & Workspaces",
            icon: "cs-windows",
            svg: "symbols/dashboard",
            prefix: "!",
            keywords: [],
            show: true,
            impl: {
                type: "js",
                queryFn: WindowsImpl.query,
                activateFn: WindowsImpl.activate,
            },
        },

        // Menu style JS providers
        power: {
            id: "power",
            name: "Power management",
            icon: "cs-power",
            svg: "power/performance-mode",
            keywords: ["shutdown", "reboot", "logout", "sleep", "lock", "hibernate", "suspend"],
            show: true,
            impl: {
                type: "js",
                queryFn: MenusImpl.queryPower,
                activateFn: MenusImpl.activatePower,
            },
        },
        system: {
            id: "system",
            name: "System",
            icon: "laptop",
            svg: "symbols/settings",
            keywords: ["tools", "elephant"],
            show: true,
            impl: {
                type: "js",
                queryFn: MenusImpl.querySystem,
                activateFn: MenusImpl.activateSystem,
            },
        },
        quickshell: {
            id: "quickshell",
            name: "Quickshell Commands",
            icon: "org.quickshell",
            keywords: ["qs"],
            show: true,
            impl: {
                type: "js",
                queryFn: MenusImpl.queryQuickshell,
                activateFn: MenusImpl.activateQuickshell,
                providerActionFn: (provider, context, action, query) => {
                    if (action === "toggleDebugMode") { System.debugMode = !System.debugMode; }
                    return { refresh: true };
                },
            },
            actions: {
                buttons: [
                    { type: "checkbox", text: "Debug Mode", action: "toggleDebugMode", checked: System.debugMode },
                ],
            },
        },

        // Static (single-entry) Providers
        unicode: {
            id: "unicode",
            name: "Unicode",
            icon: "accessories-character-map-symbolic",
            prefix: "\\",
            keywords: ["unicode", "symbols", "emoji"],
            show: false,
            impl: {
                type: "js",
                queryFn: (p, q) => { // TODO: full provider impl
                    return [{
                        identifier: "open-unicode-picker",
                        provider: "unicode",
                        text: "Unicode Picker",
                        subtext: "Open unicode-input kitten in a floating panel",
                        icon: "accessories-character-map-symbolic",
                        hints: { prefix: "\\" },
                        actions: { default: "open-picker" },
                    }];
                },
                activateFn: (p, e, a, q) => { if (a === "open-picker") { Quickshell.execDetached(["unicode-panel.sh"]); return { close: true }; } },
            },
        },
        files: {
            id: "files",
            name: "Files",
            icon: "file-manager",
            svg: "files/folder",
            prefix: "~",
            show: false,
            impl: {
                type: "js",
                queryFn: (p, q) => {
                    return [{
                        identifier: "open-folder",
                        provider: "files",
                        text: "Open " + q,
                        subtext: "Reveal in default file manager",
                        icon: "folder",
                        actions: { default: "open-folder" },
                    }]
                },
                activateFn: (p, e, a, q) => {
                    if (a === "open-folder") {
                        Quickshell.execDetached(["sh", "-c", "xdg-open " + q]);
                        return { close: true };
                    }
                },
                prefixes: "local",
            }
        }
    })

    property Component entryComp: EntryData {}

    function resolvePrefix(provider, prefix, active, query) {
        // TODO: Multi-character prefix matching / prefix chaining
        let newState = { provider: provider, prefix: query.substring(0, 1), active: false, query: query };

        // This is a little bit of optimization to avoid searching the entire provider list for a prefix match
        if (prefix === newState.prefix) { newState.active = active; }

        // FIXME: this asumes that global is the only provider that resolves prefixes, which is not true
        if (active && !newState.active) { newState.provider = "global"; }

        if (data?.[newState.provider]?.impl?.prefixes === "global" && (prefix !== newState.prefix)) {
            for (const [id, def] of Object.entries(data)) {
                if (def?.prefix === undefined) { continue; }
                if (def?.prefix == newState.prefix) {
                    newState.prefix = newState.prefix;
                    newState.provider = id;
                    newState.active = true;
                    break;
                }
            }

            if (System.debugMode) { console.log("[Launcher][prefix]", newState.prefix + " -> " + newState.provider); }
        }

        // Strip prefix from query for providers that don't handle it themselves
        if (newState.active && data?.[newState.provider]?.impl?.prefixes !== "local") {
            newState.query = query.substring(newState.prefix.length);
        }
        return newState;
    }

    // provider: The id of the provider to query
    // query: The search query to pass to the provider
    // returns null if the provider is async, otherwise returns the result of the query
    function query(provider, query) {
        if (!data[provider]) {
            console.warn(`[Launcher][query] Unknown provider '${provider}' All providers must be defined in Providers.data`);
            LauncherState.errorMessage = `Unknown provider: '${provider}'`;
            return [];
        }

        const impl = data[provider]?.impl;
        if (impl?.type) {
            switch (impl.type) {
                case "global":
                    return queryGlobal(query);
                case "providerlist":
                    return queryProviderList(query);
                case "elephant":
                    return Elephant.query(provider, query);
                case "js":
                    if (impl?.queryFn) {
                        const entries = impl.queryFn(provider, query);
                        let result = [];
                        for (const entry of entries) {
                            result.push(entryComp.createObject(null, entry));
                        }
                        return result;
                    } else {
                        console.warn(`[Launcher][query] No queryFn defined for js impl on provider: '${provider}'`);
                        LauncherState.errorMessage = `No queryFn defined for js impl on provider: '${provider}'`;
                        return [];
                    }
                default:
                    console.warn(`[Launcher][query] Unknown impl type: '${impl.type}' on provider: '${provider}'`);
                    LauncherState.errorMessage = `Unknown impl type: '${impl.type}' on provider: '${provider}'`;
                    return [];
            }
        }

        console.error(`[Launcher][query] invalid provider definition for: '${provider}'\n`);
        console.error(`[.] definition: ${JSON.stringify(data[provider])}`);
        console.error(`[.] Query: '${query}'`);
        LauncherState.errorMessage = `Invalid provider definition for: '${provider}'`;
    }

    function queryErrorEntry(text, subtext, log) {
        if (log) {  }
        return entryComp.createObject(null, {
            identifier: "query-error",
            provider: "#query-error",
            text: text,
            subtext: subtext,
            icon: "error",
            type: "error",
        });
    }

    function queryGlobal(query) {
        let result = [];
        if (!query) { return result; } // Don't search if query is empty
        const normalizedQuery = query.trim().toLowerCase();

        if (data["global"].impl?.submenus?.includes(normalizedQuery)) {
            // Exact match for provider Id
            result.push(submenuEntry("#provider", normalizedQuery));
        } else {
            // TODO! Rethink this, global needs to suport async/elephant providers
            for (const provider of data["global"].impl?.submenus ?? []) {
                if (data[provider] === undefined) { continue; }
                const name = data[provider].name.toLowerCase();
                const keywords = data[provider]?.keywords ?? [];

                // TODO: fuzzy search, curently these are limited to exact matches due to not being able to mix sync and async providers
                if (name === normalizedQuery || keywords.includes(query)) {
                    result.push(submenuEntry("#provider", provider));
                }
            }
        }

        // TODO: sync results shouldn't prevent elephant from being queried
        if (result.length !== 0) { return result; }

        const elephantResult = Elephant.query(data["global"].impl.search, query);
        if (elephantResult !== null) {
            result.push(elephantResult);
        } else {
            // TODO: async elephant query should not prevent sync results from being returned
            return null;
        }

        return result;
    }

    function queryProviderList(query) {
        // TODO: Real implementation, currently just a placeholder MVP
        const normalizedQuery = query.trim().toLowerCase();
        let providers = [];
        for (const provider in data) {
            if (data[provider].show) {
                const name = data[provider].name.toLowerCase();
                const keywords = data[provider]?.keywords ?? [];
                const prefix = data[provider]?.prefix ?? "";
                // TODO: fuzzy search
                if (provider.startsWith(normalizedQuery) || name.startsWith(normalizedQuery) || keywords.includes(query) || prefix === query) {
                    providers.push(submenuEntry("#provider", provider));
                }
            }
        }
        if (!query) {
            providers.sort((a, b) => (a.text ?? "").toLowerCase().localeCompare((b.text ?? "").toLowerCase()));
        } // TODO: sort by relevance/recency with a query
        return providers;
    }

    // provider: The id of the active provider
    // query: The search query
    // context: Extra context from the active provider for the fallback implementation
    // returns null if no fallback is available, otherwise returns the result of the fallback function
    function queryFallback(provider, query, context) {
        const fallbackProvider = data[provider]?.impl.fallback;
        if (!fallbackProvider) { return null; }
        const impl = data[fallbackProvider]?.impl;
        if (impl.fallbackFn !== undefined) {
            return impl.fallbackFn(provider, query, context);
        } else {
            console.log(`[Launcher][query][fallback] fallbackFn is undefined for: '${fallbackProvider}' which is set as the fallback for: '${provider}'`);
        }
        return null;
    }

    /// These aren't intended to be true submenus but rather entries for other providers
    // provider: The id of the active provider
    // submenu: The id of the provider to create an entry for
    // returns null if no entry is available, otherwise returns the entry data
    function submenuEntry(provider, submenu) {
        const entry = data[submenu];
        if (entry === undefined) {
            return null;
        }

        if (entry.id !== submenu) {
            // DOCS: entry.id and submenu should always be the same
            // This is an easy spot to throw a sanity check in case I decide
            // that having an id that doesn't match the key is useful in the future and forget to update old code
            // maybe it could be useful with dynamic menus / true submenus if I implement those
            console.error("[Launcher][submenuEntry] WTH!? Provider key ('" + submenu + "') does not match it's id ('" + entry.id + "')");
        }

        return entryComp.createObject(null, {
            identifier: submenu,
            provider: provider, // DOCS: Most of the time this should be set to the virtual provider '#provider'
            text: entry?.name ?? submenu,
            icon: entry?.icon ?? "applications",
            type: "submenu", // DOCS!
            hints: { prefix: entry?.prefix },
            actions: { default: "open" }, // TODO: should any provider actions be shown outside of the submenu?
        });
    }

    // provider: The id of the active provider, not necessarily the same as the entry provider in the case of global, fallbacks, or submenus
    // entry: The full entry object, a lil overkill but it includes all the data needed to activate
    // action: The activated action to perform on the entry
    // query: The current search query, if any
    function activate(provider, entry, action, query) {
        // TODO! DOCS: Should this be how activation is done? Would a activate() function on the entry itself be better?
        if (System.debugMode) {
            console.log("[Launcher][activate] Activating entry: \n[.]", JSON.stringify(entry), "\n[.] Active provider: '" + provider + "', action: '" + action + "', query: '" + query + "'");
        }
        const entryProvider = entry?.provider ?? provider; // DOCS: entry.provider should NEVER be undefined but I *REALLY* don't trust Elephant
        if (entryProvider.startsWith("#")) {
            // DOCS: should this pass entryProvider or provider?
            return activateVirtual(entryProvider, entry, action, query);
        }

        const impl = data[entryProvider]?.impl;
        if (impl?.type) {
            switch (impl.type) {
                // 'global' and 'providerlist' are meta-providers that don't produce their own entries so don't need an activate() impl
                case "global":
                case "providerlist":
                    break;
                case "elephant":
                    return Elephant.activate(entryProvider, entry, action, query);
                case "js":
                    if (impl?.activateFn) {
                        // DOCS: should this pass entryProvider or provider?
                        return impl.activateFn(entryProvider, entry, action, query);
                    } else {
                        console.warn("[Launcher][activate] no activateFn defined for js impl on provider: '" + entryProvider + "'");
                        return { close: false, errorMessage: "No activateFn defined" };
                    }
                    break;
            }
        } else {
            console.warn("[Launcher][activate] unknown impl type for provider: '" + entryProvider + "'");
            return { close: false, errorMessage: "Unknown impl type" };
        }
        return null;
    }

    // Virtual providers // TODO: ~~better name~~ too late
    function activateVirtual(provider, entry, action, query) {
        // Currently the provider passed into this function is entry.provider
        // this is here in case I change that behavior in the future
        const entryProvider = entry?.provider ?? provider;

        switch (entryProvider) {
            case "#provider": // DOCS: IDK what im doing, I need a better data format
                if (System.debugMode) {
                    console.log("[Launcher][activate] Switching active provider to: '" + entry?.identifier + "'");
                }
                // TODO! more robust method
                LauncherState.openProvider(entry?.identifier);
                return { close: false };
            case "#query-error":
                // NO-OP
                return null;
            default:
                console.log("[Launcher][activate] unknown virtual provider: '" + provider + "'");
                return { close: false, errorMessage: "Unknown virtual provider: '" + provider + "'" };
        }
    }

    function providerAction(provider, context, action, query) {
        // TODO! DOCS: Should this be how activation is done? Would a activate() function on the button itself be better?
        if (System.debugMode) {
            console.log("[Launcher][activateProviderAction] provider: '" + provider + "', action: '" + action + "', query: '" + query + "'");
        }

        const impl = data[provider]?.impl;
        if (impl?.type) {
            switch (impl.type) {
                case "global":
                    // CLEANUP: N/A
                    break;
                case "providerlist":
                    // CLEANUP: N/A
                    break;
                case "elephant":
                    return Elephant.providerAction(provider, context, action, query);
                case "js":
                    if (impl?.providerActionFn) {
                        return impl.providerActionFn(provider, context, action, query);
                    } else {
                        console.warn("[Launcher][activate] no activateFn defined for js impl on provider: '" + provider + "'");
                        return { close: false, errorMessage: "No activateFn defined" };
                    }
                    break;
            }
        } else {
            console.warn("[Launcher][activate] unknown impl type for provider: '" + provider + "'");
            return { close: false, errorMessage: "Unknown impl type" };
        }
        return null;
    }

    // provider: The id of the active provider, not necessarily the same as the entry provider in the case of global, fallbacks, or submenus
    // entry: The highlighted entry to use for autocomplete
    // context: The keyboard input and modifiers that triggered the autocomplete
    function autocomplete(provider, entry, query, context) {
        const entryProvider = entry?.provider;
        if (data?.[entryProvider]?.impl?.autocompleteFn !== undefined) {
            return data[entryProvider].impl.autocompleteFn(provider, entry, query, context); // DOCS: I think passing the active provider is more helpful than the entry provider
        } else if (data[provider]?.impl?.autocompleteFn !== undefined) {
            return data[provider].impl.autocompleteFn(provider, entry, query, context);
        }
        return null;
    }
}
