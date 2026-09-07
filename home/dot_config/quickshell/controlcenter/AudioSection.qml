import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Áudio. Volume e mute saem do serviço Pipewire (que já funciona na sua
// RightIsland). Enumeração e troca de dispositivo saem do `pactl`, cuja
// saída JSON é estável e independente da versão do Quickshell.
Section {
    id: root

    property bool panelOpen: false

    property var sinks: []
    property var sources: []
    property string defaultSink: ""
    property string defaultSource: ""

    // ------------------------------------------------------------------
    // NÃO leia Pipewire.* fora deste guarda.
    //
    // No login o pipewire cria um sink fantasma (`auto_null`) e o destrói
    // assim que enumera o hardware real. O Quickshell 0.3.0 tem um
    // use-after-free nessa transição: ele emite a mudança e o Qt reavalia
    // os bindings que leem o singleton, caindo num ponteiro liberado.
    // Segfault dentro de QQmlTypeWrapper::lookupSingletonProperty — antes
    // de qualquer `if (sink)` nosso rodar, então null-check não protege.
    //
    // O rastreamento de dependências do QML é dinâmico: se o ramo não é
    // avaliado, nenhuma dependência é registrada e o notifier não tem o
    // que reavaliar. Com `audioReady` falso no login, o control center
    // simplesmente não existe para o pipewire.
    //
    // Risco residual: trocar de placa de áudio COM o painel aberto ainda
    // pode derrubar este processo. Como ele é separado do bar, o custo é
    // um `qs -c controlcenter` e nada mais.
    // ------------------------------------------------------------------
    readonly property bool audioReady: root.panelOpen

    PwObjectTracker {
        objects: root.audioReady
            ? [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
            : []
    }

    readonly property var sink: root.audioReady ? Pipewire.defaultAudioSink : null
    readonly property var source: root.audioReady ? Pipewire.defaultAudioSource : null

    title: "áudio"
    icon: "audio"
    active: sink !== null && sink.audio !== null && !sink.audio.muted
    status: {
        if (!sink || !sink.audio) return "—"
        var out = sink.audio.muted ? "mudo" : Math.round(sink.audio.volume * 100) + "%"
        if (source && source.audio && !source.audio.muted) out += " · mic aberto"
        return out
    }

    onPanelOpenChanged: if (panelOpen) enumerate.running = true
    onExpandedChanged: if (expanded) enumerate.running = true

    Process {
        id: enumerate
        command: ["sh", "-c",
            "echo '@@SINKS'; pactl -f json list sinks; " +
            "echo '@@SOURCES'; pactl -f json list sources; " +
            "echo '@@DEFAULTSINK'; pactl get-default-sink; " +
            "echo '@@DEFAULTSOURCE'; pactl get-default-source"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var t = this.text
                    function chunk(a, b) {
                        var i = t.indexOf(a)
                        if (i < 0) return ""
                        i += a.length
                        var j = b ? t.indexOf(b, i) : t.length
                        return t.substring(i, j < 0 ? t.length : j).trim()
                    }

                    function devices(json) {
                        var out = []
                        var arr = JSON.parse(json)
                        for (var i = 0; i < arr.length; i++) {
                            var d = arr[i]
                            // Monitores são espelhos de sinks, não entradas
                            // reais — poluem a lista de microfones.
                            if (d.monitor_source !== undefined && d.name
                                && d.name.indexOf(".monitor") >= 0) continue
                            out.push({
                                name: d.name,
                                label: d.description || d.name
                            })
                        }
                        return out
                    }

                    root.sinks = devices(chunk("@@SINKS", "@@SOURCES"))
                    root.sources = devices(chunk("@@SOURCES", "@@DEFAULTSINK"))
                        .filter(function (d) { return d.name.indexOf(".monitor") < 0 })
                    root.defaultSink = chunk("@@DEFAULTSINK", "@@DEFAULTSOURCE")
                    root.defaultSource = chunk("@@DEFAULTSOURCE", null)
                } catch (e) {
                    console.warn("audio: pactl ilegível:", e)
                }
            }
        }
    }

    Process { id: setter }

    function setDefault(kind, name) {
        setter.command = ["pactl", "set-default-" + kind, name]
        setter.running = true
        if (kind === "sink") root.defaultSink = name
        else root.defaultSource = name
    }

    // ---------------- corpo ----------------

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 44
            text: "saída"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        Slider {
            Layout.fillWidth: true
            enabled: root.sink !== null && root.sink.audio !== null
            // Escala até 1.4: o bind de volume permite overamplificação.
            value: root.sink && root.sink.audio ? root.sink.audio.volume / 1.4 : 0
            fill: root.sink && root.sink.audio && root.sink.audio.volume > 1.0
                ? Theme.alert : Theme.accent
            onMoved: (v) => { if (root.sink && root.sink.audio) root.sink.audio.volume = v * 1.4 }
        }

        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: root.sink && root.sink.audio
                ? (root.sink.audio.muted ? "mudo" : Math.round(root.sink.audio.volume * 100) + "%")
                : "—"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: root.sink && root.sink.audio && root.sink.audio.muted
                ? Theme.muted : Theme.text

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.sink && root.sink.audio)
                    root.sink.audio.muted = !root.sink.audio.muted
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.preferredWidth: 44
            text: "mic"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        Slider {
            Layout.fillWidth: true
            enabled: root.source !== null && root.source.audio !== null
            value: root.source && root.source.audio ? root.source.audio.volume : 0
            // Mic aberto em vermelho, mesma inversão da RightIsland.
            fill: root.source && root.source.audio && !root.source.audio.muted
                ? Theme.alert : Theme.muted
            onMoved: (v) => { if (root.source && root.source.audio) root.source.audio.volume = v }
        }

        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: root.source && root.source.audio
                ? (root.source.audio.muted ? "mudo" : Math.round(root.source.audio.volume * 100) + "%")
                : "—"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: root.source && root.source.audio && !root.source.audio.muted
                ? Theme.alert : Theme.muted

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.source && root.source.audio)
                    root.source.audio.muted = !root.source.audio.muted
            }
        }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

    Text {
        text: "DISPOSITIVO DE SAÍDA"
        font.family: Theme.mono; font.pixelSize: Theme.fsCaption; font.letterSpacing: 0.5
        color: Theme.muted
    }

    Repeater {
        model: root.sinks
        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            label: modelData.label
            selected: modelData.name === root.defaultSink
            onActivated: root.setDefault("sink", modelData.name)
        }
    }

    Text {
        text: "DISPOSITIVO DE ENTRADA"
        font.family: Theme.mono; font.pixelSize: Theme.fsCaption; font.letterSpacing: 0.5
        color: Theme.muted
    }

    Repeater {
        model: root.sources
        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            label: modelData.label
            selected: modelData.name === root.defaultSource
            onActivated: root.setDefault("source", modelData.name)
        }
    }
}
