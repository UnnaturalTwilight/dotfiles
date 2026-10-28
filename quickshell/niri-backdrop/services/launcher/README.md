# Launcher V2 Service

```js
data = {
  <providerId>: {ProviderData},
  ...
}
```

### ProviderData
```js
{
  // The providerId, must be the same as the key in the providers object
  id: "string",

  // The human-readable display name for the provider
  name: "string",

  // The prompt text for the provider
  prompt: "string", // (optional) defaults to `name`

  // The xdg icon for the provider
  icon: "string", // (optional) defaults to none

  // The SVG icon for the provider
  svg: "string", // (optional) `icon` will be used instead

  // The shortcut prefix for the provider
  prefix: "char", // (optional) defaults to none

  // The keywords for the provider
  keywords: ["string", ...], // (optional) defaults to none

  // Whether the provider should be shown in the launcher
  show: boolean, // (optional) defaults to true

  // The implementation data for the provider
  impl: {ImplData}

  // The top-level actions of the provider
  actions: {ProviderActionsData}, // (optional) defaults to none
}
```

### ProviderActionsData
Defines actions to be displayed on the ProviderBar. Data Format TBD.

```js
{
  // Actions to be displayed as buttons on the ProviderBar
  // Each object represents a single button
  buttons: [
    {
      // The action to be performed when the button is clicked
      action: "string",

      // The type of the button
      type: "string", // one of "text", "icon", "both", "checkbox"

      // The text to display on the button
      text: "string", // [text,both,checkbox] defaults to the action

      // The svg icon to display on the button
      icon: "string", // [icon,both] defaults unknown

      // The checked state of the checkbox button
      checked: boolean, // [checkbox] defaults false

      // Whether the button should be displayed as a large icon
      // This only applys to buttons in the row of an entry
      // Entry Icon buttons are always large and providerBar buttons are always small
      large: boolean, // [icon] (optional) defaults false

      // Whether the button is a destructive action
      // This causes the button's icon to be red on hover instead of the default white
      destructive: boolean, // [icon,both] (optional) defaults false
    },
    ...
  ],

  // Defines a list of entries to be displayed in the dropdown menu
  // The action is used as the valueModel so it must be unique within the dropdown
  // Each object represents a single item in the dropdown menu
  dropdown: [
    {
      // The action to perform when the dropdown item is activated
      action: "string",

      // The text to display on the dropdown item
      text: "string", // [text] defaults to the action
    },
    ...
  ],

  // Defines a set of keyboard shortcuts for the provider
  shortcuts: [
    {
      // TODO!
    },
    ...
  ],
}
```

### ImplData
`'global'` and `'providerlist'` are special values for there respective providers.
Queries are resolved using the functions `queryGlobal("query")` and `queryProviderList("query")` respectively. Nether provider implments activation of entries as global does not supply any entries directly and all providerlist entries are activated via the virtual provider, `'#provider'`, which is responable for submenus.

Elephant providers are queried using the function `Elephant.query("provider", "query")` and their results are collected asynchronously.
Activation of entries for Elephant providers is done with `Elephant.activate("provider", "entry", "action", "query")`.

`fallbackFn` must always return results synchronously, returning `null` indicates that no fallback is available.
If `fallbackFn` is unset the provider can not be used to supply a fallback entry. The `type` field of the returned EntryData object **SHOULD** be set to `"fallback"`.
The data of the context parameter is not yet standardized and may be removed in the future.

`autocompleteFn` is called when `<Tab>` is pressed to allow providers to autofill the search bar. Any the current keyboard modifiers are passed to the function in the context object. If `autocompleteFn` is not set or null is returned, the query will not be modified. The active provider prefix, if any, is automaticaly preserved.

```js
{
  // The implementation type
  type: "string", // "global", "providerlist", "elephant", or "js"

  // This function is called for js providers to produce the list of entries for a given query
  // The function should return an array of objects, or null if the provider is async
  queryFn: function(provider, query) => [{EntryJSON}, ...] | null, // [js]
                                        ^^^^^^^^^ TODO: [(EntryData {}), ...]

  // This function is called for js providers to activate an entry
  // The function should return an object with the result of the activation or null if the activation is a no-op
  activateFn: function(provider, entry, action, query) => {ActivateResult} | null, // [js]

  // This function is called for js providers to handle provider actions
  // The return format is the same as for the activateFn so that providers that don't need entry/button data to fulfill actions can use the same implementation for both
  providerActionFn: function(provider, context, action, query) => , // [js] (optional)

  // This function is called for providers to handle fallback behavior when no entry is found
  // The function should return an EventData object, or null if no fallback is available
  fallbackFn: function(provider, query, context) => (EventData {}), // (optional)

  // This function is called for providers to autocomplete a query
  // The function should return a string to be used as the new query
  // If impl.prefixes is set to a value other than 'local' any activation prefix will automatically be preserved by the launcher.
  // If impl.prefixes is set to 'local' the provider implementation is responsible for preserving the prefix as to not de-activate itself. The context object contains the necessary information to correctly preserve the prefix.
  autocompleteFn: function(provider, entry, query, context) => "string", // (optional)

  // The string Ids of providers to query for results
  search: ["providerId", ...], // [global]

  // The string Ids of the submenu providers to use
  submenus: ["providerId", ...], // [global] (optional) defaults to none

  // The string Id of the fallback provider to use
  // The fallback provider must implement fallbackFn() and its entry will be appended to the results
  fallback: "providerId", // (optional) defaults to none

  // How the launcher should handle prefixes
  // 'global' - prefixes resolved and handled and striped from the query by the launcher
  // 'local' - prefixes are handled by the provider and not stripped from the query including when activated by a global prefix
  // '' (none) - prefixes are not resolved but are stripped from the query when the provider is activated by a global prefix
  prefixes: "string", // (optional) "global", "local", "" (none) defaults to none
}
```

### ActivateResult
```js
{
  // Indicates if the launcher should close
  close: boolean, // (optional) defaults to true

  // Indicates if the results should be refreshed
  refresh: boolean, // (optional) defaults to false

  // Indicates if the entry should be removed
  remove: boolean, // (optional) defaults to false

  // Indicates if the entry is currently being processed
  // If undefined the working state of the launcher will not be changed
  working: boolean, // (optional) defaults to undefined

  // Updates the entry with the provided data
  // Any top-level fields not present in the update will be preserved
  // Any changes to hints or actions needs to provide the full object of hints/actions
  update: {EntryJSON}, // (optional)

  // The error message to display, if any
  errorMessage: string, // (optional) defaults to none
}
```

### EntryData / EntryJSON
EntryJSON is converted to EntryData via: `EntryData.createObject(null, {EntryJSON})`
EntryData is defined in [`EntryData.qml`](./EntryData.qml)

```js
{
  // unique identifier for the entry
  identifier: "string",

  // Id of the provider that owns this entry
  provider: "string",

  // text to display for the entry
  text: "string",

  // text to display as a subtitle for the entry
  subtext: "string", // (optional), defaults to none

  // xdg theme icon to display for the entry
  // To use a svg icon add a icon button instead
  icon: "string", // (optional), defaults to none

  // Type of the entry
  // This is only used as a general hint for now and does not affect any behavior.
  // This is subject to change in the future when alternative results views are implemented.
  property string type: "item" // (optional), defaults to "item"

  // Hints for the entry
  // These are used to implement the entry's behavior and are not displayed to the user.
  // All hints are optional and will default to undefined.
  // Values listed below are examples or the non-default state.
  property var hints: ({
    active: false, // If the entry is visually enabled, if false the entry text will be drawn faded out
    prefix: "#", // The char or string to display as a prefix hint box
    monospace: true, // Whether the entry should be displayed in a monospace font
    textWrap: true, // Wrap text insted of eliding it
    maxLines: 5, // The maximum number of lines of text to display for the entry when
    preview_type: "image", // Used with 'preview' to display an image insted of text
    preview: "~/Images/example.png", // The path to the preview image to display
    autoHeight: true, // Automatically adjust the entry's height to fit the content
    buttonRowAlign: "left" // Left align the buttons for entries without text
  })

  // The actions and buttons to display for the entry
  property var actions: ({
    default: "activate" // The default action to perform when the entry is activated
    ctrl: "${default}" // The action to perform when the entry is activated with ctrl held
    alt: "${default}" // The action to perform when the entry is activated with alt held
    shift: "${default}" // The action to perform when the entry is activated with shift held
    buttons: {
      icon: { // The entry's icon is replaced with this button
        action: "", // The action to perform when the button is clicked
        text: "", // Set on the button but never displayed
        icon: "", // The svg icon to display for the button
      },
      row: [ // The main button row of the entry
        {
          action: "", // The action to perform when the button is clicked
          type: "text", // The type of button to display
          text: "", // The text to display on the button
          icon: "", // The svg icon to display for the button
          large: false, // Whether an icon button is displayed at a larger size
          checked: false, // If a checkbox button is checked or not
          destructive: false, // If the button is a destructive action
        },
        ...
      ],
      column: [ // A vertical column of icon buttons
        {
          action: "", // The action to perform when the button is clicked
          type: "icon", // All other types of buttons are forced into the size of a small icon
          text: "", // The text to display on the button
          icon: "", // The svg icon to display for the button
          checked: false, // If a checkbox button is checked or not
          destructive: false, // If the button is a destructive action
        },
        ...
      ]
    }
  })
}
```
