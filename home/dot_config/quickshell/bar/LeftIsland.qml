import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Ilha esquerda: onde você está.
//
// Não reserva espaço — quem reserva é a ilha central, que é a única das
// três ancorada de forma que o layer-shell aceite `exclusive_zone`
// (âncora numa borda só, ou numa borda mais as duas perpendiculares;
// um canto como `top+left` faz o compositor tratar o valor como zero).
PanelWindow {
    id: win

    anchors { top: true; left: true }
    margins { top: Theme.topMargin; left: Theme.sideMargin }

    implicitWidth: island.implicitWidth
    implicitHeight: Theme.islandHeight

    // Era `exclusiveZone: ExclusionMode.Ignore` — propriedade errada.
    // Isso atribuía o valor inteiro do enum a uma propriedade que espera
    // pixels, então a ilha reservava alguns pixels em silêncio.
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    Island {
        id: island
        anchors.fill: parent

        // --- Workspaces ---
        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                id: ws
                required property var modelData

                readonly property bool active: Hyprland.focusedWorkspace
                    && Hyprland.focusedWorkspace.id === modelData.id

                Layout.alignment: Qt.AlignVCenter
                implicitWidth: active ? 32 : 22
                implicitHeight: 22
                radius: 6

                color: active ? Theme.accent
                     : modelData.toplevels && modelData.toplevels.values.length > 0
                       ? Theme.surfaceAlt : "transparent"
                border.width: active ? 0 : 1
                border.color: Theme.border

                Behavior on implicitWidth {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: ws.modelData.id
                    font.family: Theme.mono
                    font.pixelSize: Theme.fsBody
                    font.weight: Font.Medium
                    color: ws.active ? Theme.base : Theme.muted
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + ws.modelData.id)
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 1
            implicitHeight: 16
            color: Theme.border
        }

        // --- Janela em foco ---
        //
        // Usamos ToplevelManager (wlr-foreign-toplevel) em vez da API de
        // janela do Hyprland: é protocolo padrão, não muda entre versões
        // do compositor.
        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 480
            elide: Text.ElideRight

            text: ToplevelManager.activeToplevel
                ? ToplevelManager.activeToplevel.title : "—"
            font.family: Theme.mono
            font.pixelSize: Theme.fsStrong
            color: Theme.text
        }
    }
}
