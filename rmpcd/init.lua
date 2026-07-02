---@diagnostic disable: undefined-global

--@type Config
local config = {}

config.address = "$XDG_RUNTIME_DIR/mpd/socket"
config.mpris = true

-- If you wish to subscribe to additional MPD channels
-- config.subscribe_channels = { "test" }

-- Automatically increment play count on song change
rmpcd.install("#builtin.playcount")

-- Tracking when a song was last played
-- https://github.com/rmpc-org/rmpcd-lastplayed/tree/master
rmpcd.install("plugins.lastplayed")

-- Install notification on song change builtin
-- rmpcd.install("#builtin.notify")

-- Install the auto lyrics download builtin
rmpcd.install("#builtin.lyrics"):setup({
     lyrics_dir = os.getenv("HOME") .. "/Music/lyrics",
})

return config
