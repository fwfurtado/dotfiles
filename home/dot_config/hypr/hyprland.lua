-- Hyprland 0.56.2 Lua profile.
-- Modules are resolved relative to this configuration directory.
require("environment")
require("core")
require("scrolling")
require("monitors")
require("rules")
require("binds")

-- For Noctalia Color templates
require("noctalia").apply_theme()
