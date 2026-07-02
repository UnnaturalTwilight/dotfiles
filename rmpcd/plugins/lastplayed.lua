-- From: https://github.com/rmpc-org/rmpcd-lastplayed/tree/master

---@type LastPlayedPlugin
local M = {
	enabled = true,
	min_seconds = nil,
	min_percent = nil,

	_current_song = nil,
	_song_play_start = nil,
	_song_elapsed = 0,
	_is_playing = false,
}

---@param self LastPlayedPlugin
---@param elapsed_seconds number
---@param duration_ms number
---@return boolean
local function should_record(self, elapsed_seconds, duration_ms)
	local has_min_seconds = self.min_seconds ~= nil
	local has_min_percent = self.min_percent ~= nil

	if not has_min_seconds and not has_min_percent then
		return true
	end

	local meets_seconds = has_min_seconds and elapsed_seconds >= self.min_seconds

	local meets_percent = false
	if has_min_percent and duration_ms and duration_ms > 0 then
		meets_percent = (elapsed_seconds * 1000 / duration_ms * 100) >= self.min_percent
	end

	return meets_seconds or meets_percent
end

---@param self LastPlayedPlugin
---@return number
local function get_total_elapsed(self)
	local elapsed = self._song_elapsed
	if self._is_playing and self._song_play_start ~= nil then
		elapsed = elapsed + (os.time() - self._song_play_start)
	end
	return elapsed
end

---@param self LastPlayedPlugin
local function reset_tracking(self, is_playing, new_song)
	self._current_song = new_song
	self._song_elapsed = 0
	self._is_playing = is_playing
	self._song_play_start = is_playing and os.time() or nil
end

M.setup = function(self, args)
	self.enabled = (args.enabled ~= nil) and args.enabled or true
	self.min_seconds = args.min_seconds
	self.min_percent = args.min_percent
end

M.song_change = function(self, old_song, new_song)
	if self.enabled and old_song ~= nil then
		local elapsed = get_total_elapsed(self)
		if should_record(self, elapsed, old_song.duration) then
			local ok, err = mpd.set_song_sticker(old_song.file, "lastPlayed", tostring(os.time()))
			if not ok then
				log.error("Error setting lastPlayed sticker for " .. old_song.file .. ": " .. (err or "unknown error"))
			end
		end
	end

	reset_tracking(self, new_song ~= nil, new_song)
end

M.state_change = function(self, _old_state, new_state)
	if new_state == "play" then
		self._song_play_start = os.time()
		self._is_playing = true
	else
		if self._is_playing and self._song_play_start ~= nil then
			self._song_elapsed = self._song_elapsed + (os.time() - self._song_play_start)
		end
		self._song_play_start = nil
		self._is_playing = false
	end
end

M.reconnect = function(self)
	reset_tracking(self, false, nil)
end

M.shutdown = function(self)
	if not self.enabled or self._current_song == nil then
		return
	end

	local elapsed = get_total_elapsed(self)
	if should_record(self, elapsed, self._current_song.duration) then
		local ok, err = mpd.set_song_sticker(self._current_song.file, "lastPlayed", tostring(os.time()))
		if not ok then
			log.error(
				"Error setting lastPlayed sticker for " .. self._current_song.file .. ": " .. (err or "unknown error")
			)
		end
	end
end

M.subscribed_channels = { "rmpcd.lastplayed" }
M.message = function(self, _channel, message)
	if message == "enable" then
		log.info("Enabling lastplayed plugin")
		self.enabled = true
	elseif message == "disable" then
		log.info("Disabling lastplayed plugin")
		self.enabled = false
	elseif message == "toggle" then
		log.info("Toggling lastplayed plugin to: " .. tostring(not self.enabled))
		self.enabled = not self.enabled
	end
end

return M
