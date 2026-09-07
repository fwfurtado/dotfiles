import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Control center. Processo separado do bar.
//   qs -c controlcenter ipc call cc toggle
ShellRoot {
    id: root

    property bool open: false
    // Uma seção aberta por vez: o painel cabe sem scroll em repouso, e
    // duas listas longas abertas juntas passariam da altura da tela útil.
    property string section: ""
    property string hint: ""

    function pick(name) { root.section = (root.section === name) ? "" : name }

    IpcHandler {
        target: "cc"
        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function close(): void { root.open = false }
    }

    onOpenChanged: if (!open) { root.section = ""; root.hint = "" }

    Process { id: session }

    // ------------------------------------------------------------------
    // UMA surface, em tela cheia, transparente.
    //
    // A tentativa anterior usava duas surfaces — um backdrop separado
    // atrás do painel — e o clique fora não chegava. Em vez de depurar
    // roteamento de ponteiro entre layer surfaces, o problema deixa de
    // existir: o "fora" agora é o fundo da MESMA janela, e um MouseArea
    // comum resolve.
    //
    // Custo: enquanto aberta, esta surface captura o ponteiro na tela
    // inteira, inclusive sobre a barra. É o comportamento de um popup
    // modal, e o clique que fecha é o mesmo que você daria de qualquer
    // forma.
    // ------------------------------------------------------------------
    PanelWindow {
        id: win
        visible: root.open

        anchors { top: true; bottom: true; left: true; right: true }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-controlcenter"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: if (visible) keys.forceActiveFocus()

        Item {
            id: keys
            anchors.fill: parent
            focus: root.open
            Keys.onEscapePressed: root.open = false

            // Fundo: qualquer clique aqui é "fora do cartão".
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: root.open = false
            }

            Rectangle {
                id: card

                // Posicionado sob a ilha de sistema, na direita.
                anchors { top: parent.top; right: parent.right }
                anchors.topMargin: 50
                anchors.rightMargin: 14

                width: 460
                height: column.implicitHeight + 26

                radius: 16
                color: Theme.surface
                border.width: 1
                border.color: Theme.border

                // Intercepta o clique antes do fundo: sem isto, clicar em
                // qualquer área vazia do cartão fecharia o painel.
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: (e) => e.accepted = true
                }

                ColumnLayout {
                    id: column
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 13
                    spacing: 2

                    AudioSection {
                        panelOpen: root.open
                        expanded: root.section === "audio"
                        onToggled: root.pick("audio")
                    }

                    NetworkSection {
                        panelOpen: root.open
                        expanded: root.section === "network"
                        onToggled: root.pick("network")
                    }

                    BluetoothSection {
                        panelOpen: root.open
                        expanded: root.section === "bluetooth"
                        onToggled: root.pick("bluetooth")
                    }

                    DisplaySection {
                        panelOpen: root.open
                        expanded: root.section === "display"
                        onToggled: root.pick("display")
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        height: 1
                        color: Theme.border
                    }

                    // ---------------- sessão ----------------
                    //
                    // Reboot e shutdown pedem confirmação: um clique
                    // acidental aqui custa caro, e com só um ícone no botão
                    // o risco de errar o alvo sobe. O primeiro clique arma
                    // (borda vermelha, ícone de check), o segundo executa,
                    // e depois de 3s desarma sozinho.
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 6

                        Repeater {
                            model: [
                                { label: "bloquear",  icon: "lock",   cmd: ["hyprlock"],                    confirm: false },
                                { label: "sair",      icon: "logout", cmd: ["hyprctl", "dispatch", "exit"], confirm: true  },
                                { label: "reiniciar", icon: "reboot", cmd: ["systemctl", "reboot"],         confirm: true  },
                                { label: "desligar",  icon: "power",  cmd: ["systemctl", "poweroff"],       confirm: true  }
                            ]

                            IconButton {
                                id: sess
                                required property var modelData
                                property bool pending: false

                                Layout.fillWidth: true
                                implicitHeight: 48
                                icon: pending ? "check" : modelData.icon
                                label: modelData.label
                                armed: pending

                                onHoveredChanged: {
                                    if (hovered) root.hint = pending
                                        ? "confirmar: " + modelData.label
                                        : modelData.label
                                    else if (root.hint.indexOf(modelData.label) >= 0)
                                        root.hint = ""
                                }

                                onActivated: {
                                    if (modelData.confirm && !pending) {
                                        pending = true
                                        root.hint = "confirmar: " + modelData.label
                                        disarm.restart()
                                        return
                                    }
                                    root.open = false
                                    session.command = modelData.cmd
                                    session.running = true
                                }

                                Timer {
                                    id: disarm
                                    interval: 3000
                                    onTriggered: {
                                        sess.pending = false
                                        if (root.hint.indexOf(sess.modelData.label) >= 0)
                                            root.hint = ""
                                    }
                                }
                            }
                        }
                    }

                    // Linha de dica compartilhada. Altura fixa para o painel
                    // não pular de tamanho quando o texto aparece e some.
                    Text {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 2
                        horizontalAlignment: Text.AlignHCenter
                        height: 18
                        text: root.hint
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsBody
                        color: root.hint.indexOf("confirmar") === 0 ? Theme.alert : Theme.muted
                        opacity: root.hint.length > 0 ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }
                }
            }
        }
    }
}
