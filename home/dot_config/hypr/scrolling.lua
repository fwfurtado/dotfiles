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
hl.bind("SUPER+F", hl.dsp.layout("center"), {
    description = "Center column",
})

-- Column navigation and movement.
hl.bind("SUPER+CTRL+left", hl.dsp.layout("focus l"), {
    description = "Focus previous column",
})
hl.bind("SUPER+CTRL+right", hl.dsp.layout("focus r"), {
    description = "Focus next column",
})
hl.bind("SUPER+CTRL+SHIFT+left", hl.dsp.layout("swapcol l"), {
    description = "Swap column left",
})
hl.bind("SUPER+CTRL+SHIFT+right", hl.dsp.layout("swapcol r"), {
    description = "Swap column right",
})

-- Move a window between columns. If the current column contains more than one
-- window, consume_or_expel detaches the focused window into its own column.
hl.bind("SUPER+ALT+left", hl.dsp.layout("consume_or_expel prev"), {
    description = "Consume or expel window left",
})
hl.bind("SUPER+ALT+right", hl.dsp.layout("consume_or_expel next"), {
    description = "Consume or expel window right",
})

-- Fast column navigation.
hl.bind("SUPER+Tab", hl.dsp.layout("focus r"), {
    description = "Focus next column",
})
hl.bind("SUPER+SHIFT+Tab", hl.dsp.layout("focus l"), {
    description = "Focus previous column",
})

-- Detach the focused window into its own column.
hl.bind("SUPER+SHIFT+M", hl.dsp.layout("promote"), {
    description = "Promote window to own column",
})

-- Cycle through the widths configured in explicit_column_widths.
hl.bind("SUPER+SHIFT+bracketleft", hl.dsp.layout("colresize -conf"), {
    description = "Previous column width preset",
})
hl.bind("SUPER+SHIFT+bracketright", hl.dsp.layout("colresize +conf"), {
    description = "Next column width preset",
})

return true

