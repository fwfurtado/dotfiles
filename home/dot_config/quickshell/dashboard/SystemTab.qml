import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Métricas do sistema em grade 2x2. Uma amostra a cada 2s, um processo `sh`
// por amostra: CPU% exige delta entre duas leituras e disco/temperatura não
// vêm de arquivo único, então um coletor só mantém tudo consistente no
// mesmo instante.
Item {
    id: root

    property bool panelOpen: false

    property real cpu: 0
    property real memUsed: 0
    property real memTotal: 0
    property real swapUsed: 0
    property real swapTotal: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property real tempC: -1
    property int cores: 0
    property string uptime: ""

    property var cpuHistory: []
    property var memHistory: []
    property var tempHistory: []
    readonly property int historyLen: 60

    // Jiffies da amostra anterior, para o delta.
    property real prevIdle: -1
    property real prevTotal: -1

    function gib(kb) { return (kb / 1048576).toFixed(1) }
    function gb(bytes) { return (bytes / 1073741824).toFixed(0) }

    function push(arr, v) {
        var out = arr.slice()
        out.push(v)
        while (out.length > root.historyLen) out.shift()
        return out
    }

    function avg(arr) {
        if (!arr || arr.length === 0) return 0
        var s = 0
        for (var i = 0; i < arr.length; i++) s += arr[i]
        return s / arr.length
    }

    function minOf(arr) {
        if (!arr || arr.length === 0) return 0
        return Math.min.apply(null, arr)
    }

    function maxOf(arr) {
        if (!arr || arr.length === 0) return 0
        return Math.max.apply(null, arr)
    }

    // Só amostra com o painel aberto: um `sh` a cada 2s eternamente para
    // desenhar um gráfico que ninguém está vendo é desperdício. O custo é
    // o sparkline começar vazio a cada abertura.
    Timer {
        interval: 2000
        running: root.panelOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!probe.running) probe.running = true
    }

    Process {
        id: probe
        command: ["sh", "-c",
            "grep '^cpu ' /proc/stat; " +
            "echo \"cores $(nproc)\"; " +
            "grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo; " +
            "df -B1 --output=size,used / | tail -1 | sed 's/^/disk /'; " +
            "for h in /sys/class/hwmon/*; do " +
            "  n=$(cat \"$h/name\" 2>/dev/null) || continue; " +
            "  case \"$n\" in k10temp|zenpower|coretemp|acpitz) " +
            "    t=$(cat \"$h/temp1_input\" 2>/dev/null) && echo \"temp $t\" && break ;; " +
            "  esac; done; " +
            "uptime -p 2>/dev/null | sed 's/^/uptime /'"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n")
                var memTotal = 0, memAvail = 0, swapTotal = 0, swapFree = 0

                for (var i = 0; i < lines.length; i++) {
                    var f = lines[i].trim().split(/\s+/)
                    if (f.length === 0 || f[0] === "") continue

                    if (f[0] === "cpu") {
                        // user nice system idle iowait irq softirq steal…
                        var total = 0
                        for (var k = 1; k < f.length; k++) total += parseFloat(f[k])
                        var idle = parseFloat(f[4]) + parseFloat(f[5] || 0)

                        if (root.prevTotal >= 0) {
                            var dt = total - root.prevTotal
                            var di = idle - root.prevIdle
                            // dt <= 0 acontece em suspend/resume: descarta a
                            // amostra em vez de plotar um pico falso.
                            if (dt > 0) {
                                root.cpu = Math.max(0, Math.min(100, (1 - di / dt) * 100))
                                root.cpuHistory = root.push(root.cpuHistory, root.cpu)
                            }
                        }
                        root.prevTotal = total
                        root.prevIdle = idle
                    }
                    else if (f[0] === "cores")         root.cores = parseInt(f[1])
                    else if (f[0] === "MemTotal:")     memTotal = parseFloat(f[1])
                    else if (f[0] === "MemAvailable:") memAvail = parseFloat(f[1])
                    else if (f[0] === "SwapTotal:")    swapTotal = parseFloat(f[1])
                    else if (f[0] === "SwapFree:")     swapFree = parseFloat(f[1])
                    else if (f[0] === "disk") {
                        root.diskTotal = parseFloat(f[1])
                        root.diskUsed = parseFloat(f[2])
                    }
                    else if (f[0] === "temp") {
                        root.tempC = parseFloat(f[1]) / 1000
                        root.tempHistory = root.push(root.tempHistory, root.tempC)
                    }
                    else if (f[0] === "uptime") root.uptime = lines[i].substring(7).trim()
                }

                root.memTotal = memTotal
                root.memUsed = memTotal - memAvail
                root.swapTotal = swapTotal
                root.swapUsed = swapTotal - swapFree
                if (memTotal > 0)
                    root.memHistory = root.push(root.memHistory,
                                                root.memUsed / memTotal * 100)
            }
        }
    }

    // `left` e `right` NÃO servem como nome de propriedade: o QQuickItem já
    // os declara como FINAL — são as linhas de âncora de `anchors.left`.
    // Sobrescrever dá "Cannot override FINAL property" e o tipo inteiro
    // fica indisponível.
    //
    // Os filhos referenciam o id do componente em vez de `parent`: dentro
    // de um layout, `parent` é o que o layout decidir, não necessariamente
    // a raiz do componente.
    component Footnote: RowLayout {
        id: fn
        property string leading: ""
        property string trailing: ""
        Layout.fillWidth: true
        spacing: 12
        Text {
            text: fn.leading
            font.family: Theme.mono; font.pixelSize: Theme.fsLabel
            color: Theme.muted
        }
        Item { Layout.fillWidth: true }
        Text {
            text: fn.trailing
            font.family: Theme.mono; font.pixelSize: Theme.fsLabel
            color: Theme.muted
        }
    }

    component DiskRow: RowLayout {
        id: dr
        property string label: ""
        property string value: ""
        property color tone: Theme.text
        Layout.fillWidth: true
        Text {
            Layout.preferredWidth: 62
            text: dr.label
            font.family: Theme.mono; font.pixelSize: Theme.fsCaption
            color: Theme.muted
        }
        Text {
            Layout.fillWidth: true
            text: dr.value
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            font.weight: Font.DemiBold
            color: dr.tone
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 12
            columnSpacing: 12

            // ---------------- CPU ----------------
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "cpu"
                title: "CPU"
                value: root.cpu.toFixed(0) + "%"
                valueColor: root.cpu >= 90 ? Theme.alert : Theme.accent

                Sparkline {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: root.cpuHistory
                    capacity: root.historyLen
                    maxValue: 100
                    stroke: Theme.accent
                }

                Footnote {
                    leading: root.cores > 0 ? root.cores + " cores" : ""
                    trailing: "avg " + root.avg(root.cpuHistory).toFixed(0) + "%"
                }
            }

            // ---------------- Memória ----------------
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "memory"
                title: "MEMORY"
                value: root.memTotal > 0
                    ? (root.memUsed / root.memTotal * 100).toFixed(0) + "%" : "—"
                valueColor: root.memUsed / root.memTotal >= 0.9 ? Theme.alert : Theme.good

                Sparkline {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: root.memHistory
                    capacity: root.historyLen
                    maxValue: 100
                    stroke: Theme.good
                }

                Footnote {
                    leading: root.memTotal > 0
                        ? root.gib(root.memUsed) + " / " + root.gib(root.memTotal) + " GiB" : ""
                    trailing: root.swapTotal > 0
                        ? "swap " + root.gib(root.swapUsed) + " GiB" : "no swap"
                }
            }

            // ---------------- Disco ----------------
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "disk"
                title: "DISK /"
                value: root.diskTotal > 0
                    ? (root.diskUsed / root.diskTotal * 100).toFixed(0) + "%" : "—"
                valueColor: root.diskUsed / root.diskTotal >= 0.85
                    ? Theme.alert : Theme.accent
                contentSpacing: 7

                // Sem sparkline: uso de disco não se move em janela de dois
                // minutos, e um gráfico plano só ocupa espaço.
                DiskRow {
                    label: "used"
                    value: root.diskTotal > 0 ? root.gb(root.diskUsed) + " GB" : "—"
                }
                DiskRow {
                    label: "free"
                    value: root.diskTotal > 0
                        ? root.gb(root.diskTotal - root.diskUsed) + " GB" : "—"
                    tone: Theme.good
                }
                DiskRow {
                    label: "total"
                    value: root.diskTotal > 0 ? root.gb(root.diskTotal) + " GB" : "—"
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 7
                    radius: 4
                    color: Theme.surfaceAlt

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        radius: 4
                        width: parent.width * (root.diskTotal > 0
                            ? Math.min(1, root.diskUsed / root.diskTotal) : 0)
                        color: root.diskUsed / root.diskTotal >= 0.85
                            ? Theme.alert : Theme.accent
                        Behavior on width {
                            NumberAnimation { duration: 380; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            // ---------------- Temperatura ----------------
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "thermometer"
                title: "TEMPERATURE"
                value: root.tempC >= 0 ? root.tempC.toFixed(0) + "°C" : "—"
                valueColor: root.tempC >= 85 ? Theme.alert : Theme.accent

                Sparkline {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: root.tempHistory
                    capacity: root.historyLen
                    // Faixa fixa 30–95: escala automática faria uma variação
                    // de 2°C parecer um pico dramático.
                    minValue: 30
                    maxValue: 95
                    stroke: root.tempC >= 85 ? Theme.alert : Theme.alert
                }

                Footnote {
                    leading: root.tempHistory.length > 0
                        ? "min " + root.minOf(root.tempHistory).toFixed(1) + "°C" : ""
                    trailing: root.tempHistory.length > 0
                        ? "max " + root.maxOf(root.tempHistory).toFixed(1) + "°C" : ""
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.tempC < 0
                    horizontalAlignment: Text.AlignHCenter
                    text: "no recognized hwmon sensor"
                    font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                    color: Theme.muted
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.uptime
            font.family: Theme.mono; font.pixelSize: Theme.fsCaption
            color: Theme.muted
            elide: Text.ElideRight
        }
    }
}
