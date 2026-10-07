-- Keybinds and submaps for Hyprland 0.56.2.
--
-- Numbered headings provide categories for the Noctalia keybind-cheatsheet;
-- descriptions contain labels only.  hl.dsp.exec_cmd() is used for every
-- external command so process startup stays asynchronous and outside Lua callbacks.

local term = "ghostty +new-window"
local browser = "google-chrome"

-- 1. Applications
hl.bind("SUPER+Return", hl.dsp.exec_cmd(term), {
    description = "Open terminal",
})
hl.bind("SUPER+CTRL+grave", hl.dsp.global("com.mitchellh.ghostty:CTRL+LOGO+grave"), {
    description = "Toggle Ghostty quick terminal",
})
hl.bind("SUPER+SHIFT+Return", hl.dsp.exec_cmd(browser), {
    description = "Open browser",
})
hl.bind("SUPER+E", hl.dsp.exec_cmd("nautilus"), {
    description = "Open file manager",
})
hl.bind("SUPER+space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), {
    description = "Open launcher",
})
hl.bind("SUPER+V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), {
    description = "Clipboard history",
})

-- 2. Focus
-- Arrow keys mirror the compositor's directional focus commands.
do
    local focus_binds = {
        { "left", "left" },
        { "down", "down" },
        { "up", "up" },
        { "right", "right" },
    }
    for _, entry in ipairs(focus_binds) do
        local key, direction = table.unpack(entry)
        hl.bind("SUPER+" .. key, hl.dsp.focus({ direction = direction }), {
            description = "Focus window " .. direction,
        })
    end
end
-- 3. Pointer move / resize
-- Keyboard movement is layout-specific and lives in scrolling.lua.
hl.bind("SUPER+mouse:272", hl.dsp.window.drag(), {
    description = "Drag window",
})
hl.bind("SUPER+mouse:273", hl.dsp.window.resize(), {
    description = "Resize with mouse",
})

-- 4. Window State
hl.bind("SUPER+Q", hl.dsp.window.close(), {
    description = "Close window",
})
hl.bind("SUPER+M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), {
    description = "Maximize (respect gaps)",
})
hl.bind("SUPER+SHIFT+M", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
    description = "Fullscreen",
})
hl.bind("SUPER+F", hl.dsp.window.float({ action = "toggle" }), {
    description = "Toggle floating",
})
hl.bind("SUPER+CTRL+P", hl.dsp.window.pin({ action = "toggle" }), {
    description = "Pin window",
})
-- 5. Workspaces
local function move_windows_current_workspace(target)
    local current = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not current then
        return
    end

    for _, window in pairs(hl.get_windows({ workspace = current })) do
        hl.dispatch(hl.dsp.window.move({
            window = window,
            workspace = target,
            follow = false,
        }))
    end

    hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
end

for workspace = 1, 9 do
    hl.bind("SUPER+" .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }), {
        description = "Go to workspace " .. workspace,
    })
end
for workspace = 1, 9 do
    hl.bind("SUPER+SHIFT+" .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }), {
        description = "Send window to workspace " .. workspace,
    })
end
for workspace = 1, 9 do
    local target = workspace
    hl.bind("SUPER+CTRL+SHIFT+" .. target, function()
        move_windows_current_workspace(target)
    end, {
        description = "Send workspace to " .. target,
    })
end
hl.bind("SUPER+Page_Up", hl.dsp.focus({ workspace = "e-1" }), {
    description = "Previous existing workspace",
})
hl.bind("SUPER+Page_Down", hl.dsp.focus({ workspace = "e+1" }), {
    description = "Next existing workspace",
})
hl.bind("SUPER+CTRL+Page_Up", hl.dsp.window.move({ workspace = "e-1", follow = false }), {
    description = "Send window to previous workspace",
})
hl.bind("SUPER+CTRL+Page_Down", hl.dsp.window.move({ workspace = "e+1", follow = false }), {
    description = "Send window to next workspace",
})
hl.bind("SUPER+grave", hl.dsp.focus({ workspace = "previous" }), {
    description = "Back to last workspace",
})

-- 6. Scratchpad
hl.bind("SUPER+S", hl.dsp.workspace.toggle_special("scratch"), {
    description = "Toggle scratchpad",
})
hl.bind("SUPER+SHIFT+S", hl.dsp.window.move({ workspace = "special:scratch", follow = true }), {
    description = "Send window to scratchpad",
})

-- 7. Screenshots
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"), {
    description = "Screenshot region",
})

-- 8. Media
-- Volume and media actions are handled by Noctalia's OSD; these binds only
-- emit events.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"), {
    repeating = true,
    description = "Volume up",
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"), {
    repeating = true,
    description = "Volume down",
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"), {
    locked = true,
    description = "Mute output",
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("noctalia msg mic-mute"), {
    locked = true,
    description = "Mute microphone",
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"), {
    locked = true,
    description = "Play / pause",
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"), {
    locked = true,
    description = "Next track",
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"), {
    locked = true,
    description = "Previous track",
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up"), {
    repeating = true,
    description = "Brightness up",
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"), {
    repeating = true,
    description = "Brightness down",
})

-- 9. System
hl.bind("SUPER+ALT+L", hl.dsp.exec_cmd("noctalia msg session lock"), {
    description = "Lock screen",
})
hl.bind("SUPER+ALT+R", hl.dsp.exec_cmd("hyprctl reload"), {
    description = "Reload Hyprland",
})
hl.bind("SUPER+ALT+Q", hl.dsp.exit(), {
    description = "Exit session",
})
hl.bind("SUPER+SHIFT+slash", hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"), {
    description = "Show keybindings",
})
hl.bind("SUPER+ALT+C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center calendar"), {
    description = "Show calendar",
})
hl.bind("SUPER+SHIFT+C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center system"), {
    description = "Show system monitor",
})

return true
