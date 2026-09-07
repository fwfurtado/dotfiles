import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray

// Ilha direita: bandeja do sistema e acesso ao control center.
//
// Mic, volume e lock saíram daqui — o control center cobre os três, e
// duplicar controle em dois lugares significa dois lugares para manter.
PanelWindow {
    id: win

    anchors { top: true; right: true }
    margins { top: Theme.topMargin; right: Theme.sideMargin }

    implicitWidth: island.implicitWidth
    implicitHeight: Theme.islandHeight
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    Process {
        id: controlCenter
        command: ["qs", "-c", "controlcenter", "ipc", "call", "cc", "toggle"]
    }

    Island {
        id: island
        anchors.fill: parent

        // --- Bandeja ---
        Repeater {
            model: SystemTray.items

            Item {
                required property var modelData
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 18
                implicitHeight: 18

                Image {
                    anchors.centerIn: parent
                    width: 16; height: 16
                    source: modelData.icon
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (e) => {
                        if (e.button === Qt.LeftButton) modelData.activate()
                        else modelData.secondaryActivate()
                    }
                }
            }
        }

        // Separador só quando há bandeja: sem itens, um traço solto antes
        // do botão fica órfão.
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            visible: SystemTray.items.values.length > 0
            implicitWidth: 1
            implicitHeight: 14
            color: Theme.border
        }

        // --- Control center ---
        //
        // Três barras: mesmo vocabulário do ícone de lista do cheatsheet.
        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 16
            implicitHeight: 16

            Column {
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    model: 3
                    Rectangle {
                        width: 12; height: 2; radius: 1
                        color: ccArea.containsMouse ? Theme.accent : Theme.muted
                        Behavior on color { ColorAnimation { duration: 110 } }
                    }
                }
            }

            MouseArea {
                id: ccArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: controlCenter.running = true
            }
        }
    }
}
