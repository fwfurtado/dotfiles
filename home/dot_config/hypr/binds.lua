-- Keybinds and submaps for Hyprland 0.56.2.
--
-- Descriptions intentionally retain the group::subgroup::label format used by
-- the Quickshell cheatsheet.  hl.dsp.exec_cmd() is used for every external
-- command so process startup stays asynchronous and outside Lua callbacks.

local term = "ghostty +new-window"
local browser = "google-chrome"
local launcher = "fuzzel"

-- Applications.
hl.bind("SUPER+Return", hl.dsp.exec_cmd(term), {
    description = "apps::Open terminal",
})
hl.bind("SUPER+CTRL+grave", hl.dsp.global("com.mitchellh.ghostty:CTRL+LOGO+grave"), {
    description = "apps::Toggle Ghostty quick terminal",
})
hl.bind("SUPER+SHIFT+Return", hl.dsp.exec_cmd(browser), {
    description = "apps::Open browser",
})
hl.bind("SUPER+E", hl.dsp.exec_cmd("nautilus"), {
    description = "apps::Open file manager",
})
hl.bind("SUPER+space", hl.dsp.exec_cmd("qs -c omni ipc call omni all"), {
    description = "apps::Open launcher",
})
hl.bind("SUPER+V", hl.dsp.exec_cmd("cliphist list | " .. launcher .. " --dmenu | cliphist decode | wl-copy"), {
    description = "apps::Clipboard history",
})

-- Focus. hjkl follows tiling conventions; mirrored arrows are convenient
-- while the hand is on the mouse.
do
    local focus_binds = {
        { "H", "left", "Focus window left" },
        { "J", "down", "Focus window down" },
        { "K", "up", "Focus window up" },
        { "L", "right", "Focus window right" },
        { "left", "left", "Focus window left" },
        { "down", "down", "Focus window down" },
        { "up", "up", "Focus window up" },
        { "right", "right", "Focus window right" },
    }
    for _, entry in ipairs(focus_binds) do
        local key, direction, label = table.unpack(entry)
        hl.bind("SUPER+" .. key, hl.dsp.focus({ direction = direction }), {
            description = "focus::" .. label,
        })
    end
end

-- Master-layout actions.
hl.bind("SUPER+M", hl.dsp.layout("focusmaster"), {
    description = "focus::Master::Focus master window",
})
hl.bind("SUPER+SHIFT+M", hl.dsp.layout("swapwithmaster"), {
    description = "focus::Master::Swap with master",
})
hl.bind("SUPER+Tab", hl.dsp.layout("cyclenext"), {
    description = "focus::Master::Next in stack",
})
hl.bind("SUPER+SHIFT+Tab", hl.dsp.layout("cycleprev"), {
    description = "focus::Master::Previous in stack",
})
hl.bind("SUPER+comma", hl.dsp.layout("addmaster"), {
    description = "focus::Master::Add master slot",
})
hl.bind("SUPER+period", hl.dsp.layout("removemaster"), {
    description = "focus::Master::Remove master slot",
})

-- Move windows.
do
    local move_binds = {
        { "H", "left", "Move window left" },
        { "J", "down", "Move window down" },
        { "K", "up", "Move window up" },
        { "L", "right", "Move window right" },
        { "left", "left", "Move window left" },
        { "down", "down", "Move window down" },
        { "up", "up", "Move window up" },
        { "right", "right", "Move window right" },
    }
    for _, entry in ipairs(move_binds) do
        local key, direction, label = table.unpack(entry)
        hl.bind("SUPER+SHIFT+" .. key, hl.dsp.window.move({ direction = direction }), {
            description = "move::" .. label,
        })
    end
end
hl.bind("SUPER+mouse:272", hl.dsp.window.drag(), {
    description = "move::Drag window",
})
hl.bind("SUPER+mouse:273", hl.dsp.window.resize(), {
    description = "move::Resize with mouse",
})

-- Window state.
hl.bind("SUPER+Q", hl.dsp.window.close(), {
    description = "window::Close window",
})
hl.bind("SUPER+CTRL+F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
    description = "window::Fullscreen",
})
hl.bind("SUPER+CTRL+M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), {
    description = "window::Maximize (respect gaps)",
})
hl.bind("SUPER+CTRL+space", hl.dsp.window.float({ action = "toggle" }), {
    description = "window::Toggle floating",
})
hl.bind("SUPER+CTRL+P", hl.dsp.window.pin({ action = "toggle" }), {
    description = "window::Pin window",
})
hl.bind("SUPER+SHIFT+R", hl.dsp.exec_cmd("hyprctl --batch \"dispatch layoutmsg mfact exact $mfact ; dispatch layoutmsg orientationcenter\""), {
    description = "window::Reset layout",
})

-- Resize mode.  The submap function scopes these binds to resize.  Escape
-- and Return explicitly select reset, matching the legacy submap block.
hl.bind("SUPER+R", hl.dsp.submap("resize"), {
    description = "window::Enter resize mode",
})
hl.define_submap("resize", function()
    hl.bind("H", hl.dsp.window.resize({ x = -80, y = 0, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Narrow window",
    })
    hl.bind("L", hl.dsp.window.resize({ x = 80, y = 0, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Widen window",
    })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Shrink height",
    })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Grow height",
    })
    hl.bind("left", hl.dsp.window.resize({ x = -80, y = 0, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Narrow window",
    })
    hl.bind("right", hl.dsp.window.resize({ x = 80, y = 0, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Widen window",
    })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Shrink height",
    })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), {
        repeating = true,
        description = "window::Resize mode::Grow height",
    })
    hl.bind("Escape", hl.dsp.submap("reset"), {
        description = "window::Resize mode::Leave resize mode",
    })
    hl.bind("Return", hl.dsp.submap("reset"), {
        description = "window::Resize mode::Leave resize mode",
    })
end)

-- Workspaces.
for workspace = 1, 9 do
    hl.bind("SUPER+" .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }), {
        description = "workspace::Go to workspace " .. workspace,
    })
end
for workspace = 1, 9 do
    hl.bind("SUPER+SHIFT+" .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }), {
        description = "workspace::Send::Send window to workspace " .. workspace,
    })
end
for workspace = 1, 9 do
    hl.bind("SUPER+CTRL+SHIFT+" .. workspace, hl.dsp.exec_cmd("~/.config/hypr/scripts/move-workspace.sh " .. workspace), {
        description = "workspace::Send all::Send workspace to " .. workspace,
    })
end
hl.bind("SUPER+bracketleft", hl.dsp.focus({ workspace = "e-1" }), {
    description = "workspace::Previous existing workspace",
})
hl.bind("SUPER+bracketright", hl.dsp.focus({ workspace = "e+1" }), {
    description = "workspace::Next existing workspace",
})
hl.bind("SUPER+grave", hl.dsp.focus({ workspace = "previous" }), {
    description = "workspace::Back to last workspace",
})

-- Scratchpad.
hl.bind("SUPER+S", hl.dsp.workspace.toggle_special("scratch"), {
    description = "workspace::Scratchpad::Toggle scratchpad",
})
hl.bind("SUPER+SHIFT+S", hl.dsp.window.move({ workspace = "special:scratch", follow = true }), {
    description = "workspace::Scratchpad::Send window to scratchpad",
})

-- Screenshots.
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | swappy -f -"), {
    description = "capture::Region to editor",
})
hl.bind("SHIFT+Print", hl.dsp.exec_cmd("grim - | wl-copy"), {
    description = "capture::Screen to clipboard",
})
hl.bind("SUPER+Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"), {
    description = "capture::Region to clipboard",
})

-- Media and volume are handled by Quickshell's OSD; these only emit events.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), {
    repeating = true,
    description = "media::Volume up",
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    repeating = true,
    description = "media::Volume down",
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true,
    description = "media::Mute output",
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true,
    description = "media::Mute microphone",
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true,
    description = "media::Play / pause",
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true,
    description = "media::Next track",
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true,
    description = "media::Previous track",
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), {
    repeating = true,
    description = "media::Brightness up",
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), {
    repeating = true,
    description = "media::Brightness down",
})
hl.bind("SUPER+backslash", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true,
    description = "media::Mute microphone",
})

-- System.
hl.bind("SUPER+ALT+L", hl.dsp.exec_cmd("hyprlock"), {
    description = "system::Lock screen",
})
hl.bind("SUPER+ALT+R", hl.dsp.exec_cmd("hyprctl reload"), {
    description = "system::Reload Hyprland",
})
hl.bind("SUPER+ALT+Q", hl.dsp.exit(), {
    description = "system::Exit session",
})
hl.bind("SUPER+SHIFT+slash", hl.dsp.exec_cmd("qs -c cheatsheet ipc call cheatsheet toggle"), {
    description = "system::Show keybindings",
})
hl.bind("SUPER+C", hl.dsp.exec_cmd("qs -c dashboard ipc call dashboard openTab calendar"), {
    description = "system::Show calendar",
})
hl.bind("SUPER+SHIFT+C", hl.dsp.exec_cmd("qs -c dashboard ipc call dashboard openTab system"), {
    description = "system::Show system monitor",
})

return true
