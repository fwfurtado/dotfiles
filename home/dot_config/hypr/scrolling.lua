-- Dynamic centered-master behavior on top of Hyprland's scrolling layout.
--
-- The scrolling layout remains responsible for the infinite horizontal tape.
-- This module only enforces a visual invariant on the active workspace:
--
--     [ 25% ] [ focused: 50% ] [ 25% ]
--
-- Columns outside the viewport keep participating in the scrolling tape at
-- 25%. Whenever focus changes, the focused tiled column is resized to 50%
-- and centered.

local M = {}

local side_width = 0.25
local focused_width = 0.50

hl.config({
    scrolling = {
        column_width = side_width,
        explicit_column_widths = "0.25, 0.50",
        focus_fit_method = 0,
        follow_focus = true,
        follow_min_visible = 0.0,
        wrap_focus = true,
        wrap_swapcol = true,
        direction = "right",
    },
})

function M.center_focused()
    local window = hl.get_active_window()
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

    if not window or window.floating or not workspace then
        return
    end

    if workspace.tiled_layout ~= "scrolling" then
        return
    end

    hl.dispatch(hl.dsp.layout("colresize all " .. side_width))
    hl.dispatch(hl.dsp.layout("colresize " .. focused_width))
    hl.dispatch(hl.dsp.layout("center"))
end

hl.on("window.active", function()
    M.center_focused()
end)

hl.on("workspace.active", function()
    M.center_focused()
end)

hl.on("config.reloaded", function()
    M.center_focused()
end)

return M

