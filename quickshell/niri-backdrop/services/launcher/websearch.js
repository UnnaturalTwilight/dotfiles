// websearch.js
/// Impl for the websearch provider

const engineData = {
  google: {
    prefix: "@google",
    displayName: "Google",
    displayQuery: "Search google for ",
    icon: "applications-internet",
    action: "search-google",
    searchUrl: "https://www.google.com/search?q=",
    baseUrl: "https://www.google.com",
  },
  archwiki: {
    prefix: "@arch",
    displayName: "Arch Wiki",
    displayQuery: "Search the arch wiki for ",
    icon: "stock_addressbook",
    action: "search-archwiki",
    searchUrl: "https://wiki.archlinux.org/index.php?search=",
    baseUrl: "https://wiki.archlinux.org",
  },
  wikipedia: {
    prefix: "@wiki",
    displayName: "Wikipedia",
    displayQuery: "Search wikipedia for ",
    icon: "preferences-desktop-search",
    action: "search-wikipedia",
    searchUrl: "https://en.wikipedia.org/w/index.php?search=",
    baseUrl: "https://en.wikipedia.org",
  },
  github: {
    prefix: "@gh",
    displayName: "GitHub",
    displayQuery: "Search github for ",
    icon: "github-desktop",
    action: "search-github",
    searchUrl: "https://github.com/search?type=repositories&q=",
    baseUrl: "https://github.com",
  },
  aur: {
    prefix: "@aur",
    displayName: "AUR",
    displayQuery: "Search AUR for ",
    icon: "package",
    action: "search-aur",
    searchUrl: "https://aur.archlinux.org/packages/?O=0&K=",
    baseUrl: "https://aur.archlinux.org",
  },
  cheifdelfi: {
    prefix: "@cd",
    displayName: "ChiefDelphi",
    displayQuery: "Search chiefdelfi for ",
    icon: "",
    action: "search-cheifdelfi",
    searchUrl: "https://www.chiefdelphi.com/search?q=",
    baseUrl: "https://www.chiefdelphi.com/",
  },
  print: {
    prefix: "@print",
    displayName: "Printables",
    displayQuery: "Search printables for ",
    icon: "printer",
    action: "search-printables",
    searchUrl: "https://www.printables.com/search?q=",
    baseUrl: "https://www.printables.com",
  },
};

function query(provider, query) {
  if (!query) { return list(provider, query); }
  const split = query?.split(" ");
  const prefix = split ? split?.[0] : "";
  if (!prefix || split.length < 2) { return list(provider, query); }
  let engine = "";
  for (const [name, e] of Object.entries(engineData)) {
    if (`@${name}` === prefix || (e?.prefix === prefix)) {
      engine = name;
      break;
    }
  }
  let normalizedQuery = query.trim();
  if (!engine) { return list(provider, normalizedQuery); }
  if (normalizedQuery.startsWith(engine)) {
    normalizedQuery = normalizedQuery.slice(engine.length).trim();
  } else if (normalizedQuery.startsWith(engineData[engine].prefix)) {
    normalizedQuery = normalizedQuery.slice(engineData[engine].prefix.length).trim();
  }
  return [searchEngineEntry(engine, normalizedQuery)];
}

function list(provider, query) {
  let results = [];
  let idx = 0;
  for (const [name, e] of Object.entries(engineData)) {
    let score = 20 + idx++;
    if (e.prefix === undefined) {
      score += 20;
    } else if (e.prefix === query) {
      score -= 10;
    } else if (e.prefix.startsWith(query)) {
      score -= 5;
    }
    if (`@${name}`.startsWith(query)) { score--; }

    let normalizedQuery = query;
    if (query === `@${name}`) {
      normalizedQuery = query.slice(name.length + 1).trim();
    } else if (query === e.prefix) {
      normalizedQuery = query.slice(e.prefix.length).trim();
    } else if (query.startsWith("@")) {
      normalizedQuery = query.slice(1).trim();
    }
    results.push({ engine: name, query: normalizedQuery, score})
  }

  results.sort((a, b) => a.score - b.score);
  let entries = [];

  entries.push(searchEngineEntry(results[0].engine, results[0].query));

  entries.push({
    identifier: "prefix-buttons",
    provider: "websearch",
    text: "",
    subtext: "",
    icon: "",
    hints: { buttonRowAlign: "left", autoHeight: true },
    actions: {
      buttons: {
        row: results.slice(1, 6).map(result => ({
          action: engineData[result.engine]?.action, type: "text",
          text: (engineData[result.engine]?.displayName ?? result.engine) + " " + engineData[result.engine]?.prefix
        }))
      }
    },
  })

  return entries;
}

function searchEngineEntry(engineId, query, small = false) {
  return {
    identifier: `${engineId}-websearch`,
    provider: "websearch",
    text: query ? engineData[engineId].displayQuery + `“${query}”` : engineData[engineId].displayName,
    subtext: small ? "" : "Search the interwebs",
    icon: small ? "" : engineData[engineId].icon,
    hints: { prefix: engineData[engineId]?.prefix ?? "", search_engine: engineId, autoHeight: small },
    actions: {
      default: engineData[engineId]?.action,
    },
  };
}

function activate(provider, entry, action, query) {
  if (action.startsWith("search")) {
    const engineId = entry.hints?.search_engine || action.slice(7) || "google";
    const engine = engineData[engineId];
    let url;
    let normalizedQuery = query.trim();

    if (entry.type !== "fallback") {
      if (normalizedQuery.split(" ")[0] === engine.prefix) {
        normalizedQuery = normalizedQuery.slice(engine.prefix.length).trim();
      } else if (normalizedQuery.split(" ")[0] === ("@" + entry.hints?.search_engine)) {
        normalizedQuery = normalizedQuery.slice(entry.hints.search_engine.length + 1).trim();
      } else if (normalizedQuery.startsWith("@")) {
        normalizedQuery = normalizedQuery.slice(1).trim();
      }
    }

    if (normalizedQuery) {
      url = `${engine.searchUrl}${encodeURIComponent(normalizedQuery)}`;
    } else {
      url = engine.baseUrl;
    }

    const cmd = ["xdg-open", url];
    Quickshell.execDetached(cmd);
    return { close: true };
  }
  return null;
}

function fallback(provider, query, context) {
  if (!query.trim()) { return null; }
  // FIXME: consistency -> should js providers be returning json or EntryData objects?
  return entryComp.createObject(null, {
    identifier: "fallback-websearch",
    provider: "websearch",
    text: engineData.google.displayQuery + `“${query.trim()}”`,
    subtext: context ?? "Search the interwebs",
    icon: "applications-internet",
    type: "fallback",
    actions: { default: engineData.google.action },
  });
}

function autocomplete(provider, entry, query, context) {
  query = query.trim();
  if (query.split(" ").length > 1) { return null; }
  const engine = entry.hints?.search_engine;
  const prefix = entry.hints?.prefix;
  if (!engine || !prefix) { return null; }

  if (!query.startsWith("@")) { query = "@" + query; }
  if (prefix.startsWith(query)) { return prefix + " "; }

  return null;
}
