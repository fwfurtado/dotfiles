-- Window and layer rules for Hyprland 0.56.2.
--
-- Rules are registered in this file rather than through legacy hyprlang.  Keep
-- them anonymous and in source order: Hyprland evaluates anonymous rules in
-- registration order, and matching effects are intentionally unchanged.

-- Screen sharing: the portal picker must stay above the tiled layout.
hl.window_rule({
    match = { class = "^(xdg-desktop-portal-hyprland|hyprland-share-picker)$" },
    float = true,
    center = true,
    stay_focused = true,
    pin = true,
    no_anim = true,
})

-- The share bar receives its final title after mapping.  Keep this as a
-- to the windowtitlev2 event, rather than relying on a one-shot map rule.
hl.window_rule({
    match = { title = "^(.*is sharing.*)$" },
    no_screen_share = true,
})

-- Dialogs: on a 5120px monitor, a tiled save dialog occupies half the screen.
hl.window_rule({
    match = { title = "^(Open File|Save File|Save As|Abrir|Salvar como)$" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
    float = true,
    center = true,
    size = { 1200, 800 },
})
hl.window_rule({
    match = { class = "^(blueman-manager)$" },
    float = true,
    center = true,
    size = { 1200, 800 },
})
hl.window_rule({
    match = { class = "^(nm-connection-editor)$" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { class = "^(hyprpolkitagent|polkit-gnome-authentication-agent-1)$" },
    float = true,
    center = true,
})

-- VS Code / devcontainers.
hl.window_rule({
    match = { class = "^(code|Code|code-url-handler)$" },
    workspace = "2",
})
hl.window_rule({
    match = { class = "^(code|Code)$" },
    idle_inhibit = "focus",
})

-- Communication on workspace 9.
hl.window_rule({
    match = { class = "^(Slack|discord|vesktop)$" },
    workspace = "9",
})
hl.window_rule({
    match = { class = "^(zoom)$" },
    workspace = "9",
})
hl.window_rule({
    match = { class = "^(zoom|firefox|chromium|google-chrome)$" },
    idle_inhibit = "fullscreen",
})
hl.window_rule({
    match = { title = "^(.*Meet.*|.*Zoom Meeting.*)$" },
    idle_inhibit = "focus",
})

-- Picture-in-picture: anchor it on the right, away from the center column.
hl.window_rule({
    match = { title = "^(Picture-in-Picture|Picture in picture)$" },
    float = true,
    pin = true,
    size = { 640, 360 },
    move = { "100%-680", "100%-420" },
})

-- Scratchpad.
hl.window_rule({
    match = { workspace = "special:scratch" },
    float = true,
    center = true,
    size = { 2000, 1200 },
})

-- Layer rules for Quickshell.  Do not add blur to the full-screen surfaces
-- (control center, dashboard, or omni); their visible cards are inner panels.
hl.layer_rule({
    match = { namespace = "quickshell-bar" },
    blur = true,
})
hl.layer_rule({
    match = { namespace = "quickshell-notifications" },
    blur = true,
})
hl.layer_rule({
    match = { namespace = "quickshell-osd" },
    blur = true,
})
hl.layer_rule({
    match = { namespace = "launcher" },
    blur = true,
})

return true
