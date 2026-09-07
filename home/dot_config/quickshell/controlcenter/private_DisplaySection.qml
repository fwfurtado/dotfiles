import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Display via wl-gammarelay-rs (DBus, wlr-gamma-control).
//
// Por que não ddcutil: o Neo G9 não implementa DDC/CI — o barramento I2C
// existe e o EDID é lido em 0x50, mas o endereço 0x37 não responde.
// Sem controle de backlight, sobra ajuste por LUT de gamma.
//
// Por que não hyprsunset: ele não faz brilho, e nas versões sem a API do
// hyprctl a única forma de mudar temperatura é matar e respawnar o daemon.
// Aqui é set-property e pronto.
Section {
    id: root

    property bool panelOpen: false

    property int state: 0             // 0=sondando 1=disponível 2=indisponível
    property int temperature: 6500
    property real brightness: 1.0
    property bool inverted: false
    property string hint: ""

    readonly property string bus: "rs.wl-gammarelay / rs.wl.gammarelay"
    readonly property bool neutral: temperature >= 6500 && brightness >= 0.995

    title: "display"
    icon: "display"
    available: state !== 2
    active: !neutral
    status: {
        if (state === 2) return ""
        if (state === 0) return "…"
        return temperature + "K · " + Math.round(brightness * 100) + "%"
    }

    Component.onCompleted: probe.running = true
    onPanelOpenChanged: if (panelOpen) probe.running = true

    Process {
        id: probe
        command: ["sh", "-c",
            "busctl --user get-property " + root.bus + " Temperature 2>/dev/null || exit 3; " +
            "busctl --user get-property " + root.bus + " Brightness; " +
            "busctl --user get-property " + root.bus + " Inverted"]

        stdout: StdioCollector {
            onStreamFinished: {
                // Cada linha vem como "<assinatura> <valor>": "q 5000",
                // "d 0.8", "b true".
                var l = this.text.trim().split("\n")
                if (l.length < 2) { root.state = 2; return }

                var t = parseInt((l[0] || "").split(/\s+/)[1])
                var b = parseFloat((l[1] || "").split(/\s+/)[1])
                if (isNaN(t) || isNaN(b)) { root.state = 2; return }

                root.temperature = t
                root.brightness = b
                root.inverted = (l[2] || "").indexOf("true") >= 0
                root.state = 1
            }
        }

        onExited: (code) => { if (code !== 0) root.state = 2 }
    }

    // busctl responde em poucos milissegundos, então não há debounce:
    // o slider aplica ao vivo. Era o ddcutil que exigia isso.
    Process { id: setter }

    function setProp(name, sig, value) {
        setter.command = ["busctl", "--user", "set-property",
                          "rs.wl-gammarelay", "/", "rs.wl.gammarelay",
                          name, sig, String(value)]
        setter.running = true
    }

    function setTemperature(k) {
        root.temperature = k
        setProp("Temperature", "q", k)
    }

    function setBrightness(v) {
        root.brightness = v
        setProp("Brightness", "d", v.toFixed(3))
    }

    function reset() {
        root.temperature = 6500
        root.brightness = 1.0
        setProp("Temperature", "q", 6500)
        // Encadeado: dois Process concorrentes no mesmo id se atropelam.
        resetBrightness.running = true
    }

    function applyPreset(k, b) {
        root.setTemperature(k)
        root.brightness = b
        applyPresetBrightness.command = [
            "busctl", "--user", "set-property",
            "rs.wl-gammarelay", "/", "rs.wl.gammarelay",
            "Brightness", "d", b.toFixed(3)]
        applyPresetBrightness.running = true
    }

    Process { id: applyPresetBrightness }

    Process {
        id: resetBrightness
        command: ["busctl", "--user", "set-property",
                  "rs.wl-gammarelay", "/", "rs.wl.gammarelay",
                  "Brightness", "d", "1.0"]
    }

    // ---------------- corpo ----------------

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 60
            text: "brilho"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        Slider {
            Layout.fillWidth: true
            // Piso em 20%: abaixo disso a LUT já achatou tanto o sinal que
            // a tela fica ilegível, e o slider vira uma armadilha.
            value: (root.brightness - 0.2) / 0.8
            onMoved: (v) => root.setBrightness(0.2 + v * 0.8)
        }

        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.brightness * 100) + "%"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.text
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 60
            text: "temp"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        Slider {
            Layout.fillWidth: true
            value: (root.temperature - 2000) / 4500
            step: 0.02
            fill: root.temperature < 6500 ? Theme.alert : Theme.accent
            onMoved: (v) => root.setTemperature(
                Math.round((2000 + v * 4500) / 100) * 100)
        }

        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: root.temperature + "K"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.text
        }
    }

    // Presets como ícones: a progressão sol → sol baixo → lua → livro
    // carrega a ideia melhor que quatro palavras, e o rótulo continua
    // acessível na linha de dica abaixo.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { label: "dia",     icon: "sun",    k: 6500, b: 1.0  },
                    { label: "tarde",   icon: "sunset", k: 5000, b: 0.9  },
                    { label: "noite",   icon: "moon",   k: 4000, b: 0.75 },
                    { label: "leitura", icon: "book",   k: 3000, b: 0.6  }
                ]

                IconButton {
                    required property var modelData
                    Layout.fillWidth: true
                    icon: modelData.icon
                    label: modelData.label
                    active: root.temperature === modelData.k
                        && Math.abs(root.brightness - modelData.b) < 0.01
                    onActivated: root.applyPreset(modelData.k, modelData.b)
                    onHoveredChanged: if (hovered) root.hint = modelData.label
                                      else if (root.hint === modelData.label) root.hint = ""
                }
            }
        }
    }


    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        IconButton {
            Layout.fillWidth: true
            icon: "reset"
            label: "restaurar neutro"
            enabled: !root.neutral
            onActivated: root.reset()
            onHoveredChanged: if (hovered) root.hint = "restaurar neutro"
                              else if (root.hint === "restaurar neutro") root.hint = ""
        }

        IconButton {
            Layout.fillWidth: true
            icon: "invert"
            label: "inverter cores"
            active: root.inverted
            onActivated: {
                root.inverted = !root.inverted
                root.setProp("Inverted", "b", root.inverted ? "true" : "false")
            }
            onHoveredChanged: if (hovered) root.hint = "inverter cores"
                              else if (root.hint === "inverter cores") root.hint = ""
        }
    }

    // Linha de dica compartilhada: reserva altura fixa para o painel não
    // pular de tamanho quando o texto aparece e some.
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        height: 14
        text: root.hint
        font.family: Theme.mono; font.pixelSize: Theme.fsCaption
        color: Theme.muted
        opacity: root.hint.length > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Text {
        Layout.fillWidth: true
        visible: root.state === 2
        text: "wl-gammarelay-rs não está no barramento. "
            + "cargo install wl-gammarelay-rs, e exec-once = wl-gammarelay-rs"
        wrapMode: Text.WordWrap
        font.family: Theme.mono; font.pixelSize: Theme.fsCaption
        color: Theme.muted
    }
}
