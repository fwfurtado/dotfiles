import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Rede via nmcli. Modo terse (-t) com separador ":" é a interface de
// script do NetworkManager — estável entre versões, ao contrário da
// saída tabular.
//
// Escopo deliberado: mostra o estado, alterna o rádio Wi-Fi e conecta a
// redes JÁ SALVAS. Conectar numa rede nova exige prompt de senha, o que
// significa reimplementar um diálogo de credenciais dentro de um shell —
// para isso o botão abre o nm-connection-editor.
Section {
    id: root

    property bool panelOpen: false

    property string primary: ""       // descrição da conexão ativa
    property string primaryType: ""
    property bool wifiRadio: false
    property bool wifiPresent: false
    property var networks: []
    property string busySsid: ""

    title: "rede"
    // Cabo e Wi-Fi têm ícones distintos: o estado que importa aqui
    // é por onde o tráfego está saindo, não que "existe rede".
    icon: primaryType === "802-3-ethernet" ? "ethernet" : "network"
    active: primary.length > 0
    status: primary.length > 0 ? primary : "desconectado"

    onPanelOpenChanged: if (panelOpen) refresh.running = true
    onExpandedChanged: if (expanded) refresh.running = true

    Timer {
        interval: 10000
        running: root.expanded
        repeat: true
        onTriggered: if (!refresh.running) refresh.running = true
    }

    Process {
        id: refresh
        command: ["sh", "-c",
            "echo '@@ACTIVE'; nmcli -t -f NAME,TYPE,DEVICE connection show --active; " +
            "echo '@@RADIO'; nmcli -t radio wifi; " +
            "echo '@@DEV'; nmcli -t -f TYPE device; " +
            "echo '@@WIFI'; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null; " +
            "echo '@@SAVED'; nmcli -t -f NAME connection show"]

        stdout: StdioCollector {
            onStreamFinished: {
                var t = this.text
                function chunk(a, b) {
                    var i = t.indexOf(a)
                    if (i < 0) return []
                    i += a.length
                    var j = b ? t.indexOf(b, i) : t.length
                    return t.substring(i, j < 0 ? t.length : j).trim().split("\n")
                        .filter(function (l) { return l.length > 0 })
                }

                // Conexão ativa: cabo ganha de Wi-Fi na exibição, porque é
                // a rota que realmente está sendo usada nesta máquina.
                var act = chunk("@@ACTIVE", "@@RADIO")
                var best = null
                for (var i = 0; i < act.length; i++) {
                    var f = act[i].split(":")
                    if (f[1] === "loopback" || f[1] === "tun") continue
                    if (best === null || f[1] === "802-3-ethernet") best = f
                }
                root.primary = best ? best[0] : ""
                root.primaryType = best ? best[1] : ""

                root.wifiRadio = chunk("@@RADIO", "@@DEV").join("").indexOf("enabled") >= 0
                root.wifiPresent = chunk("@@DEV", "@@WIFI").join(" ").indexOf("wifi") >= 0

                var saved = {}
                var s = chunk("@@SAVED", null)
                for (var k = 0; k < s.length; k++) saved[s[k]] = true

                var seen = {}
                var nets = []
                var w = chunk("@@WIFI", "@@SAVED")
                for (var n = 0; n < w.length; n++) {
                    // nmcli escapa ":" dentro de campos como "\:" — separar
                    // por ":" não precedido de barra.
                    var g = w[n].split(/(?<!\\):/)
                    var ssid = (g[1] || "").replace(/\\:/g, ":")
                    if (ssid.length === 0 || seen[ssid]) continue
                    seen[ssid] = true
                    nets.push({
                        ssid: ssid,
                        inUse: g[0] === "*",
                        signal: parseInt(g[2] || "0"),
                        secure: (g[3] || "").length > 0,
                        saved: saved[ssid] === true
                    })
                }
                nets.sort(function (a, b) { return b.signal - a.signal })
                root.networks = nets.slice(0, 8)
                root.busySsid = ""
            }
        }
    }

    Process {
        id: action
        onRunningChanged: if (!running) refresh.running = true
    }

    function run(args) {
        action.command = args
        action.running = true
    }

    // ---------------- corpo ----------------

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: root.primaryType === "802-3-ethernet" ? "conexão cabeada ativa"
                : root.primary.length > 0 ? "wi-fi: " + root.primary
                : "sem conexão"
            font.family: Theme.mono; font.pixelSize: Theme.fsStrong
            color: Theme.text
            elide: Text.ElideRight
        }

        Text {
            visible: root.wifiPresent
            text: "wi-fi"
            font.family: Theme.mono; font.pixelSize: Theme.fsStrong
            color: Theme.muted
        }

        Toggle {
            visible: root.wifiPresent
            checked: root.wifiRadio
            onToggled: root.run(["nmcli", "radio", "wifi",
                                 root.wifiRadio ? "off" : "on"])
        }
    }

    Text {
        visible: !root.wifiPresent
        text: "nenhuma interface wi-fi detectada"
        font.family: Theme.mono; font.pixelSize: Theme.fsBody
        color: Theme.muted
    }

    Repeater {
        model: root.wifiRadio ? root.networks : []

        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            label: modelData.ssid
            selected: modelData.inUse
            busy: root.busySsid === modelData.ssid
            detail: {
                var bars = modelData.signal >= 75 ? "▮▮▮"
                    : modelData.signal >= 50 ? "▮▮ "
                    : modelData.signal >= 25 ? "▮  " : "   "
                return (modelData.secure ? "🔒 " : "")
                    + (modelData.saved ? "" : "novo ") + bars
            }
            onActivated: {
                if (modelData.inUse) return
                if (!modelData.saved) {
                    // Rede nova precisa de senha: delega ao editor do NM em
                    // vez de reimplementar um prompt de credenciais aqui.
                    root.run(["nm-connection-editor"])
                    return
                }
                root.busySsid = modelData.ssid
                root.run(["nmcli", "connection", "up", "id", modelData.ssid])
            }
        }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: [
                { label: "editor de conexões", cmd: ["nm-connection-editor"] },
                { label: "reescanear", cmd: ["nmcli", "device", "wifi", "rescan"] }
            ]

            Rectangle {
                id: btn
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 34
                radius: 8
                color: btnArea.containsMouse ? Theme.surfaceAlt : "transparent"
                border.width: 1
                border.color: Theme.border

                Text {
                    anchors.centerIn: parent
                    text: btn.modelData.label
                    font.family: Theme.mono; font.pixelSize: Theme.fsBody
                    color: Theme.muted
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.run(btn.modelData.cmd)
                }
            }
        }
    }
}
