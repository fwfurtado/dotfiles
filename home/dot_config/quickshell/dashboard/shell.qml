import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Dashboard: calendar / weather / system.
// Disparado pelo clique na ilha central:
//   qs -c dashboard ipc call dashboard toggle
//
// Processo separado do bar de propósito: polling de /proc e curl de clima
// não têm por que dividir processo com a barra.
ShellRoot {
    id: root

    property bool open: false
    property int tab: 0
    readonly property var tabs: [
        { id: "calendar", icon: "calendar" },
        { id: "weather",  icon: "cloud"    },
        { id: "system",   icon: "activity" }
    ]

    IpcHandler {
        target: "dashboard"
        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function close(): void { root.open = false }
        // Abre direto numa aba: ipc call dashboard openTab weather
        function openTab(name: string): void {
            for (var i = 0; i < root.tabs.length; i++)
                if (root.tabs[i].id === name) { root.tab = i; break }
            root.open = true
        }
    }

    // UMA surface em tela cheia, transparente. O "fora" do cartão é o fundo
    // desta mesma janela, então fechar no clique fora é um MouseArea comum
    // — sem depender de roteamento de ponteiro entre layer surfaces.
    PanelWindow {
        visible: root.open

        anchors { top: true; bottom: true; left: true; right: true }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-dashboard"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: if (visible) keys.forceActiveFocus()

        Item {
            id: keys
            anchors.fill: parent
            focus: root.open

            Keys.onEscapePressed: root.open = false
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_1) { root.tab = 0; e.accepted = true }
                else if (e.key === Qt.Key_2) { root.tab = 1; e.accepted = true }
                else if (e.key === Qt.Key_3) { root.tab = 2; e.accepted = true }
                else if (e.key === Qt.Key_Tab) {
                    root.tab = (root.tab + 1) % root.tabs.length
                    e.accepted = true
                }
                else if (e.key === Qt.Key_Backtab) {
                    root.tab = (root.tab + root.tabs.length - 1) % root.tabs.length
                    e.accepted = true
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: root.open = false
            }

            Rectangle {
                id: card

                // Alinhado ao topo e centralizado: a ilha que dispara este
                // painel também é a central.
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                anchors.topMargin: 50

                width: 880
                height: 720

                radius: 16
                color: Theme.surface
                border.width: 1
                border.color: Theme.border

                // Intercepta antes do fundo: sem isto, clicar em qualquer
                // área vazia do cartão fecharia o painel.
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: (e) => e.accepted = true
                }

                // ---------------- abas ----------------
                Row {
                    id: tabBar
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 12
                    height: 42
                    spacing: 5

                    Repeater {
                        model: root.tabs

                        Rectangle {
                            id: tabBtn
                            required property var modelData
                            required property int index
                            readonly property bool active: root.tab === index

                            width: (tabBar.width - tabBar.spacing * (root.tabs.length - 1))
                                / root.tabs.length
                            height: tabBar.height
                            radius: 10
                            color: active ? Theme.surfaceAlt
                                 : tabArea.containsMouse ? Theme.base : "transparent"
                            border.width: 1
                            border.color: active ? Theme.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 110 } }
                            Behavior on border.color { ColorAnimation { duration: 110 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: tabBtn.modelData.icon
                                    size: 18
                                    color: tabBtn.active ? Theme.accent : Theme.muted
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tabBtn.modelData.id
                                    font.family: Theme.mono
                                    font.pixelSize: Theme.fsBody
                                    font.weight: tabBtn.active ? Font.DemiBold : Font.Normal
                                    color: tabBtn.active ? Theme.accent : Theme.muted
                                }
                            }

                            MouseArea {
                                id: tabArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.tab = tabBtn.index
                            }
                        }
                    }
                }

                Rectangle {
                    id: sep
                    anchors { left: parent.left; right: parent.right; top: tabBar.bottom }
                    anchors.topMargin: 8
                    height: 1
                    color: Theme.border
                }

                // ---------------- conteúdo ----------------
                //
                // As três abas ficam instanciadas: o SystemTab precisa de
                // histórico contínuo para o sparkline, e o WeatherTab não
                // deve refazer o curl a cada troca de aba.
                Item {
                    anchors {
                        left: parent.left; right: parent.right
                        top: sep.bottom; bottom: parent.bottom
                    }
                    anchors.margins: 14

                    CalendarTab {
                        anchors.fill: parent
                        visible: root.tab === 0
                    }
                    WeatherTab {
                        anchors.fill: parent
                        visible: root.tab === 1
                        panelOpen: root.open
                    }
                    SystemTab {
                        anchors.fill: parent
                        visible: root.tab === 2
                        panelOpen: root.open
                    }
                }
            }
        }
    }
}
