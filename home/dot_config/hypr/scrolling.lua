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
        -- column_width = side_width,
        -- explicit_column_widths = "0.25, 0.75",
        -- focus_fit_method = 0,
        -- follow_focus = true,
        -- follow_min_visible = 0.0,
        -- wrap_focus = true,
        -- wrap_swapcol = true,
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

