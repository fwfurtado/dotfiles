import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

// OSD de volume. Substitui o swayosd, que não está empacotado no Ubuntu.
//
// Aparece perto do centro-baixo: é o único ponto de 5120px que você
// garantidamente está olhando.
Scope {
    id: root

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    readonly property var sink: Pipewire.defaultAudioSink
    property bool showing: false

    // Só mostra em MUDANÇA. Sem isto o OSD pisca no boot, quando o
    // Pipewire publica o valor inicial.
    property bool primed: false

    Connections {
        target: root.sink && root.sink.audio ? root.sink.audio : null

        function onVolumeChanged() { root.trigger() }
        function onMutedChanged()  { root.trigger() }
    }

    function trigger() {
        if (!primed) { primed = true; return }
        showing = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: root.showing = false
    }

    // Uma janela por tela. Sem isto a surface nasce amarrada ao wl_output
    // que existia na criação — e o `hyprctl dispatch dpms on` do hypridle
    // destrói e recria o output a cada retorno de ociosidade, deixando o
    // OSD sem superfície pelo resto do dia.
    //
    // O estado (ready, tracker, sink, Connections, timers) fica FORA: é do
    // processo, não da tela. Duplicá-lo faria N trackers do Pipewire.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors { bottom: true }
            margins.bottom: 160

            implicitWidth: 260
            implicitHeight: 52
            visible: root.showing

            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-osd"
            mask: Region {}   // puramente visual, não intercepta clique

            Rectangle {
                anchors.fill: parent
                color: Theme.surface
                radius: Theme.islandRadius
                border.width: 1
                border.color: Theme.border

                Text {
                    id: label
                    anchors {
                        left: parent.left; leftMargin: 16
                        top: parent.top; topMargin: 10
                    }
                    text: {
                        if (!root.sink || !root.sink.audio) return ""
                        if (root.sink.audio.muted) return "mudo"
                        return Math.round(root.sink.audio.volume * 100) + "%"
                    }
                    font.family: Theme.mono
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.sink && root.sink.audio && root.sink.audio.muted
                        ? Theme.muted : Theme.text
                }

                Text {
                    anchors {
                        right: parent.right; rightMargin: 16
                        baseline: label.baseline
                    }
                    text: root.sink ? root.sink.description : ""
                    font.family: Theme.mono
                    font.pixelSize: 10
                    color: Theme.muted
                    elide: Text.ElideRight
                    width: 140
                    horizontalAlignment: Text.AlignRight
                }

                Rectangle {
                    anchors {
                        left: parent.left; right: parent.right
                        bottom: parent.bottom
                        leftMargin: 16; rightMargin: 16; bottomMargin: 14
                    }
                    height: 3
                    radius: 2
                    color: Theme.surfaceAlt

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        radius: 2
                        // Escala até 1.4 porque o bind de volume permite
                        // overamplificação até 140%.
                        width: parent.width * Math.min(1,
                            (root.sink && root.sink.audio ? root.sink.audio.volume : 0) / 1.4)
                        color: root.sink && root.sink.audio && root.sink.audio.volume > 1.0
                            ? Theme.alert : Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}

