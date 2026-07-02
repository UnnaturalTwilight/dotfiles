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

Header:children_remove(1, Header.RIGHT)

-- Selecion & yanked counter
Header:children_add(function()
    local selected = #cx.active.selected
    local yanked = #cx.yanked
    local selected_span = ui.Span(string.format(" %2s 󱊁 ", selected)):fg(th.mgr.count_selected:bg()):bold()
    local copy_span
    if cx.yanked.is_cut and yanked > 0 then
        copy_span = ui.Span(string.format(" %2s  ", yanked)):fg(th.mgr.count_cut:bg()):bold()
    else
        copy_span = ui.Span(string.format(" %2s  ", yanked)):fg(th.mgr.count_copied:bg()):bold()
    end

    return ui.Line { copy_span, selected_span, " " }
end, 1000, Header.RIGHT)

-- Status:children_remove(1, Status.LEFT)
Status:children_remove(2, Status.LEFT)
Status:children_remove(5, Status.RIGHT)

-- Hidden files
Status:children_add(function(self)
    local hidden_mode = cx.active.pref.show_hidden
    local style = self:style()

    local span
    if hidden_mode then
        span = ui.Span(" 󰘓 "):style(style.alt)
    else
        span = ui.Span(" 󰘓 "):style(style.alt):dim()
    end

    return ui.Line {
        " ",
        ui.Span(th.status.sep_right.open):fg(style.alt:bg()),
        span,
    }
end, 2000, Status.RIGHT)

-- Folder icon / File size
Status:children_add(function(self)
    local h = self._current.hovered
    local len = h and h.cha.len or 0
    local style = self:style()
    local line = ui.Span(" -- "):style(style.alt):bold()
    if h and h.cha.is_dir then
        line = ui.Span("   "):style(style.alt):bold()
    elseif h then
        line = ui.Span(" " .. ya.readable_size(len) .. " "):style(style.alt):bold()
    end

    return ui.Line {
        line,
        ui.Span(th.status.sep_left.close):fg(style.alt:bg()),
    }
end, 2000, Status.LEFT)

-- Simlink display
Status:children_add(function(self)
    local h = self._current.hovered
    if h and h.link_to then
        return " -> " .. tostring(h.link_to)
    else
        return ""
    end
end, 3100, Status.LEFT)

-- User/Group display
Status:children_add(function(self)
    local h = self._current.hovered
    if not h or ya.target_family() ~= "unix" then
        return ""
    end

    if ya.user_name(h.cha.uid) == ya.group_name(h.cha.gid) then
        return ui.Line {
            " ",
            ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
            " ",
        }
    end

    return ui.Line {
        " ",
        ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
        ":",
        ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
        " ",
    }
end, 900, Status.RIGHT)
