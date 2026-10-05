-- Dynamic centered-master behavior on top of Hyprland's scrolling layout.
--
-- The scrolling layout remains responsible for the infinite horizontal tape.
-- This module enforces a visual invariant on the active workspace:
--
--     first focused:  [ focused: expands ][ 25% ]
--     middle focused: [ 25% ][ focused: 50% ][ 25% ]
--     last focused:   [ 25% ][ focused: expands ]
--
-- Interior columns use a centered 50% master. The first and last columns use
-- `fit expand`, allowing the focused edge column to consume all space that
-- would otherwise be left empty while keeping the adjacent column visible.

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

local function is_edge_column(window, workspace)
    local layout = window.layout
    local column = layout and layout.column

    if not layout or layout.name ~= "scrolling" or not column or column.index == nil then
        return false
    end

    local first_index = math.huge
    local last_index = -math.huge

    for _, candidate in pairs(hl.get_windows({ workspace = workspace })) do
        if not candidate.floating then
            local candidate_layout = candidate.layout
            local candidate_column = candidate_layout and candidate_layout.column

            if candidate_layout
                and candidate_layout.name == "scrolling"
                and candidate_column
                and candidate_column.index ~= nil
            then
                first_index = math.min(first_index, candidate_column.index)
                last_index = math.max(last_index, candidate_column.index)
            end
        end
    end

    return column.index == first_index or column.index == last_index
end

function M.center_focused()
    local window = hl.get_active_window()
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

    if not window or window.floating or not workspace then
        return
    end

    if workspace.tiled_layout ~= "scrolling" then
        return
    end

    local edge_column = is_edge_column(window, workspace)

    hl.dispatch(hl.dsp.layout("colresize all " .. side_width))

    if edge_column then
        hl.dispatch(hl.dsp.layout("fit expand"))
        return
    end

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

