-- Identidade da sessão.
-- XDG_CURRENT_DESKTOP é o que o xdg-desktop-portal usa para escolher backend.
-- Com GNOME instalado ao lado, errar isso = screen share quebrado.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Toolkits.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron / VS Code.
-- ELECTRON_OZONE_PLATFORM_HINT=auto faz Electron rodar em Wayland nativo:
-- fontes nítidas, sem borrão de XWayland.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Cursor. Sem isso o cursor some ou fica gigante em apps XWayland.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")

-- GPU.
-- AMD: nada a fazer, RADV é o default e funciona.

-- Keyboard Layout.
hl.env("GTK_IM_MODULE", "gtk-im-context-simple")
hl.env("QT_IM_MODULE", "compose")
hl.env("XMODIFIERS", "@im=none")
