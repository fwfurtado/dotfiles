-- Layout: master com orientação central.
--
-- Em 32:9 o dwindle é inutilizável: duas janelas viram dois painéis de
-- 2560px, cada um com linhas de ~400 colunas. O padrão que funciona é
-- "cockpit": janela principal centralizada com largura fixa, satélites nas
-- bordas — que é exatamente orientation=center.
hl.config({
    general = {
        layout = "master",
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = "rgba(7fb4c9ff)",
            inactive_border = "rgba(2a2f3aff)",
        },
        resize_on_border = true,
        allow_tearing = false,
    },
})

hl.config({
    master = {
        new_status = "slave", -- nova janela não rouba o master
        new_on_top = false,
        mfact = 0.42, -- ~2150px de master em 5120px: uma coluna de código honesta
        orientation = "center",
        slave_count_for_center_master = 1, -- já centraliza com 1 satélite
    },
})

-- Aparência.
hl.config({
    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 0.96,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            -- 5120x1440 é MUITA área para blur. Se sentir latência de compositor,
            -- este é o primeiro switch a desligar.
            popups = true,
        },

        -- Sombra só em janelas flutuantes: em 32:9 você vê muitas bordas tiled
        -- ao mesmo tempo e a sombra vira ruído.
        shadow = {
            enabled = false,
            range = 18,
            render_power = 2,
            color = "rgba(00000055)",
        },
    },
})

-- Curvas curtas de propósito: num monitor desta largura, animação longa de
-- movimento horizontal atravessa meio metro de tela e cansa.
hl.config({
    animations = {
        enabled = true,
    },
})
hl.curve("snap", { type = "bezier", points = { { 0.2, 0.9 }, { 0.3, 1.0 } } })
hl.curve("ease", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "snap", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "snap", style = "popin 92%" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "ease" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "snap", style = "slidefade 15%" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "snap", style = "fade" })

-- Input.
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "mac",
        kb_model = "pc105",
        kb_options = "lv3:ralt_switch",
        repeat_rate = 40,
        repeat_delay = 300,
        follow_mouse = 1,
        sensitivity = 0.4,
        accel_profile = "adaptive", -- desktop: sem aceleração, previsível

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
        },
    },
})

-- Miscellaneous compositor behavior. Since 0.55, VFR lives in debug.
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 0, -- VRR is intentionally disabled globally; see monitors.lua.
        focus_on_activate = true,
        middle_click_paste = false,
    },
    debug = {
        vfr = true, -- não renderiza a 120Hz quando nada muda
    },
})

hl.config({
    cursor = {
        no_hardware_cursors = false,
        inactive_timeout = 5,
    },
})

-- Workspace swipe gesture.
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    scale = 0.5,
    action = "workspace",
})
