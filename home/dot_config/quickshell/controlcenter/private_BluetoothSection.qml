import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Bluetooth via bluetoothctl não-interativo. Cada invocação é um comando
// único; nada de manter um pty aberto.
//
// Escopo: liga/desliga o rádio, lista dispositivos JÁ PAREADOS e conecta
// ou desconecta. Parear exige confirmação de PIN e agente — fluxo próprio,
// que o botão delega ao blueman-manager.
Section {
    id: root

    property bool panelOpen: false

    property bool powered: false
    property bool present: true
    property var devices: []
    property string busyMac: ""

    title: "bluetooth"
    icon: "bluetooth"
    active: powered
    available: present
    status: {
        if (!present) return ""
        if (!powered) return "desligado"
        var c = devices.filter(function (d) { return d.connected })
        return c.length > 0 ? c[0].name : "nenhum conectado"
    }

    onPanelOpenChanged: if (panelOpen) refresh.running = true
    onExpandedChanged: if (expanded) refresh.running = true

    Timer {
        interval: 8000
        running: root.expanded
        repeat: true
        onTriggered: if (!refresh.running) refresh.running = true
    }

    Process {
        id: refresh
        // `devices Paired` lista pareados; `info` de cada um diz se está
        // conectado. Um subshell só para não pagar N processos do QML.
        command: ["sh", "-c",
            "command -v bluetoothctl >/dev/null || { echo '@@ABSENT'; exit 0; }; " +
            "echo '@@POWER'; bluetoothctl show | grep -i 'Powered:' || echo 'none'; " +
            "echo '@@DEVICES'; " +
            "bluetoothctl devices Paired 2>/dev/null | while read -r _ mac name; do " +
            "  st=$(bluetoothctl info \"$mac\" 2>/dev/null | grep -c 'Connected: yes'); " +
            "  echo \"$mac|$st|$name\"; " +
            "done"]

        stdout: StdioCollector {
            onStreamFinished: {
                var t = this.text
                if (t.indexOf("@@ABSENT") >= 0) { root.present = false; return }
                root.present = true

                function chunk(a, b) {
                    var i = t.indexOf(a)
                    if (i < 0) return ""
                    i += a.length
                    var j = b ? t.indexOf(b, i) : t.length
                    return t.substring(i, j < 0 ? t.length : j).trim()
                }

                var p = chunk("@@POWER", "@@DEVICES")
                root.powered = p.toLowerCase().indexOf("yes") >= 0

                var out = []
                var lines = chunk("@@DEVICES", null).split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var f = lines[i].split("|")
                    if (f.length < 3) continue
                    out.push({
                        mac: f[0].trim(),
                        connected: f[1].trim() !== "0",
                        name: f.slice(2).join("|").trim()
                    })
                }
                // Conectados primeiro: é neles que você vai clicar.
                out.sort(function (a, b) {
                    if (a.connected !== b.connected) return a.connected ? -1 : 1
                    return a.name.localeCompare(b.name)
                })
                root.devices = out
                root.busyMac = ""
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
            text: root.powered ? "adaptador ligado" : "adaptador desligado"
            font.family: Theme.mono; font.pixelSize: Theme.fsStrong
            color: Theme.text
        }

        Toggle {
            checked: root.powered
            onToggled: root.run(["bluetoothctl", "power",
                                 root.powered ? "off" : "on"])
        }
    }

    Repeater {
        model: root.powered ? root.devices : []

        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            label: modelData.name
            selected: modelData.connected
            busy: root.busyMac === modelData.mac
            detail: modelData.connected ? "conectado" : ""
            onActivated: {
                root.busyMac = modelData.mac
                root.run(["bluetoothctl",
                          modelData.connected ? "disconnect" : "connect",
                          modelData.mac])
            }
        }
    }

    Text {
        visible: root.powered && root.devices.length === 0
        text: "nenhum dispositivo pareado"
        font.family: Theme.mono; font.pixelSize: Theme.fsBody
        color: Theme.muted
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 34
        radius: 8
        color: mgrArea.containsMouse ? Theme.surfaceAlt : "transparent"
        border.width: 1
        border.color: Theme.border

        Text {
            anchors.centerIn: parent
            text: "parear novo dispositivo"
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        MouseArea {
            id: mgrArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.run(["blueman-manager"])
        }
    }
}
