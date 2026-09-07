pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Coletores de itens, um por fonte.
//
// CADA COLETOR É ENVOLTO EM try/catch DE PROPÓSITO. As superfícies de API
// usadas aqui — DesktopEntries, ToplevelManager, Hyprland.workspaces — são
// exatamente as que mais se movem entre versões do Quickshell. Sem o
// guarda, um nome de propriedade errado derrubaria o menu inteiro; com
// ele, a fonte quebrada simplesmente não aparece e as outras continuam
// funcionando. O erro vai para o log.
Singleton {
    id: root

    property bool iconWarned: false

    readonly property var kinds: ({
        app:       { icon: "app",       label: "applications" },
        window:    { icon: "window",    label: "windows"      },
        workspace: { icon: "workspace", label: "workspaces"   },
        bind:      { icon: "keyboard",  label: "keybindings"  },
        action:    { icon: "power",     label: "session"      }
    })

    // Resolve um nome de ícone contra o tema instalado. `check: true` faz
    // o Quickshell devolver string vazia quando não existe, em vez de uma
    // textura de ícone faltando — o que permite cair no desenho.
    //
    // Três tentativas porque o campo Icon do .desktop e o appId Wayland
    // divergem em convenção: uns usam o nome curto ("firefox"), outros o
    // ID reverso completo ("dev.zed.Zed"). O tema costuma indexar só um
    // dos dois.
    function resolveIcon(name) {
        if (!name || name.length === 0) return ""
        try {
            var direct = Quickshell.iconPath(name, true)
            if (direct.length > 0) return direct

            var lower = Quickshell.iconPath(name.toLowerCase(), true)
            if (lower.length > 0) return lower

            var tail = name.split(".").pop()
            if (tail !== name) {
                var t = Quickshell.iconPath(tail.toLowerCase(), true)
                if (t.length > 0) return t
            }
        } catch (err) {
            // Loga UMA vez em vez de engolir: um catch silencioso aqui
            // transforma "nenhum ícone aparece" num problema sem pista.
            if (!root.iconWarned) {
                root.iconWarned = true
                console.warn("omni: Quickshell.iconPath indisponível:", err)
            }
        }
        return ""
    }

    // ---------------- aplicações ----------------
    function apps() {
        var out = []
        try {
            var list = DesktopEntries.applications.values
            for (var i = 0; i < list.length; i++) {
                var e = list[i]
                if (e.noDisplay) continue
                var extra = e.genericName || e.comment || ""
                out.push({
                    kind: "item",
                    type: "app",
                    label: e.name,
                    detail: extra,
                    entry: e,
                    art: root.resolveIcon(e.icon),
                    haystack: e.name + "  " + extra + "  " + (e.id || "")
                })
            }
        } catch (err) {
            console.warn("omni: fonte 'apps' indisponível:", err)
        }
        return out
    }

    // ---------------- janelas abertas ----------------
    function windows() {
        var out = []
        try {
            var list = ToplevelManager.toplevels.values
            for (var i = 0; i < list.length; i++) {
                var t = list[i]
                if (!t.title || t.title.length === 0) continue
                out.push({
                    kind: "item",
                    type: "window",
                    label: t.title,
                    detail: t.appId || "",
                    toplevel: t,
                    art: root.resolveIcon(t.appId || ""),
                    haystack: t.title + "  " + (t.appId || "")
                })
            }
        } catch (err) {
            console.warn("omni: fonte 'windows' indisponível:", err)
        }
        return out
    }

    // ---------------- workspaces ----------------
    function workspaces() {
        var out = []
        try {
            var list = Hyprland.workspaces.values
            for (var i = 0; i < list.length; i++) {
                var w = list[i]
                var n = w.toplevels && w.toplevels.values
                    ? w.toplevels.values.length : 0
                out.push({
                    kind: "item",
                    type: "workspace",
                    label: "workspace " + w.id,
                    detail: n === 1 ? "1 window" : n + " windows",
                    workspaceId: w.id,
                    haystack: "workspace " + w.id + " " + (w.name || "")
                })
            }
        } catch (err) {
            console.warn("omni: fonte 'workspaces' indisponível:", err)
        }
        return out
    }

    // ---------------- binds ----------------
    // Recebe o JSON já lido de `hyprctl -j binds`; a chamada do processo
    // fica no shell.qml para não ter um Process dentro de um singleton.
    function binds(raw) {
        var out = []
        try {
            for (var i = 0; i < raw.length; i++) {
                var b = raw[i]
                if (!b.dispatcher || b.dispatcher === "mouse") continue

                var mods = ""
                if (b.modmask & 64) mods += "SUPER+"
                if (b.modmask & 8)  mods += "ALT+"
                if (b.modmask & 4)  mods += "CTRL+"
                if (b.modmask & 1)  mods += "SHIFT+"

                var sub = b.submap && b.submap.length > 0 ? b.submap : ""
                var combo = (sub ? "[" + sub + "] " : "") + mods + b.key
                var action = b.dispatcher + (b.arg ? " " + b.arg : "")

                // A flag `d` (bindd) preenche description; ela pode vir no
                // formato "group::subgroup::texto" que o cheatsheet usa.
                var parts = (b.description || "").split("::")
                var desc = parts[parts.length - 1].trim()

                out.push({
                    kind: "item",
                    type: "bind",
                    label: desc.length > 0 ? desc : action,
                    detail: combo,
                    dispatcher: b.dispatcher,
                    arg: b.arg || "",
                    haystack: combo + "  " + desc + "  " + action
                })
            }
        } catch (err) {
            console.warn("omni: fonte 'binds' indisponível:", err)
        }
        return out
    }

    // ---------------- ações de sessão ----------------
    function actions() {
        return [
            { kind: "item", type: "action", label: "Lock screen",
              detail: "hyprlock", command: ["hyprlock"],
              haystack: "lock screen bloquear tela hyprlock" },
            { kind: "item", type: "action", label: "Reload Hyprland",
              detail: "hyprctl reload", command: ["hyprctl", "reload"],
              haystack: "reload hyprland recarregar config" },
            { kind: "item", type: "action", label: "Control center",
              detail: "quickshell",
              command: ["qs", "-c", "controlcenter", "ipc", "call", "cc", "toggle"],
              haystack: "control center painel controle audio rede" },
            { kind: "item", type: "action", label: "Dashboard",
              detail: "quickshell",
              command: ["qs", "-c", "dashboard", "ipc", "call", "dashboard", "toggle"],
              haystack: "dashboard calendar weather system calendario clima" },
            { kind: "item", type: "action", label: "Log out",
              detail: "hyprctl dispatch exit",
              command: ["hyprctl", "dispatch", "exit"],
              haystack: "log out sair encerrar sessao exit" },
            { kind: "item", type: "action", label: "Reboot",
              detail: "systemctl reboot", command: ["systemctl", "reboot"],
              haystack: "reboot reiniciar restart" },
            { kind: "item", type: "action", label: "Shut down",
              detail: "systemctl poweroff", command: ["systemctl", "poweroff"],
              haystack: "shut down desligar poweroff shutdown" }
        ]
    }
}
