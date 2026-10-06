-- Focus-driven master behavior on top of Hyprland's scrolling layout.
--
-- Hyprland's scrolling layout owns viewport movement through `follow_focus`.
-- This module only enforces column widths when focus changes:
--
--     focused column: 50%
--     every other column: 25%
--
-- No explicit centering or edge handling is performed here.

local M = {}

local side_width = 0.25
local focused_width = 0.75

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.5,
        focus_fit_method = 1,
        follow_focus = true,
        follow_min_visible = 0.4,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
        wrap_focus = true,
        wrap_swapcol = true,
        direction = "right",
    },
})

function M.resize_focused()
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
end

-- hl.on("window.active", function()
--     M.resize_focused()
-- end)

return M

