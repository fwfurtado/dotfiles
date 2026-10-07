-- Scrolling layout configuration and layout-specific keybindings.
--
-- Keep layout-specific behavior here so binds.lua remains independent from
-- the active tiling algorithm. Switching layouts should only require loading
-- another layout module.

hl.config({
    general = {
        layout = "scrolling",
    },
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

-- Centering is explicit; normal focus movement uses scrolling:focus_fit_method.
hl.bind("SUPER+C", hl.dsp.layout("center"), {
    description = "Center column",
})

-- Match Niri's Mod+Ctrl+arrow movement semantics. Horizontal movement swaps
-- the active column; vertical movement reorders the focused window in-column.
hl.bind("SUPER+CTRL+left", hl.dsp.layout("swapcol l"), {
    description = "Move column left",
})
hl.bind("SUPER+CTRL+right", hl.dsp.layout("swapcol r"), {
    description = "Move column right",
})
hl.bind("SUPER+CTRL+up", hl.dsp.window.move({ direction = "up" }), {
    description = "Move window up",
})
hl.bind("SUPER+CTRL+down", hl.dsp.window.move({ direction = "down" }), {
    description = "Move window down",
})

-- Consume / expel matches Niri's Mod+[ and Mod+].
hl.bind("SUPER+bracketleft", hl.dsp.layout("consume_or_expel prev"), {
    description = "Consume or expel window left",
})
hl.bind("SUPER+bracketright", hl.dsp.layout("consume_or_expel next"), {
    description = "Consume or expel window right",
})

-- Cycle through the widths configured in explicit_column_widths.
hl.bind("SUPER+R", hl.dsp.layout("colresize +conf"), {
    description = "Next column width preset",
})
hl.bind("SUPER+SHIFT+R", hl.dsp.layout("colresize -conf"), {
    description = "Previous column width preset",
})

return true

