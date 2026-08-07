---@diagnostic disable: undefined-global

-- require("session"):setup({ sync_yanked = true })
require("starship"):setup()
-- require("fuse-archive"):setup()
require("git"):setup({ order = 500 })
require("full-border"):setup({ type = ui.Border.ROUNDED })

require("sort-by-location"):setup {
    default = { by = 'natural', reverse = false }, -- required
    { pattern = '.*/Images/.*',  sort = { by = 'mtime', reverse = true } },
    { pattern = '.*/Downloads$', sort = { by = 'mtime', reverse = true } },
}

require("osc5522"):setup()

function Root:clipboard(event)
    ya.dbg("Clipboard:", event.type)
    require("osc5522"):handle_clipboard_event(event)
end

require("unnatural-ui"):setup()
