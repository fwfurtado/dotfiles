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

    // ------------------------------------------------------------------
    // NÃO leia Pipewire.* antes de `ready`.
    //
    // No login o pipewire cria um sink fantasma (`auto_null`) e o destrói
    // assim que enumera o hardware real. O Quickshell 0.3.0 tem um
    // use-after-free nessa transição: emite a mudança e o Qt reavalia os
    // bindings que leem o singleton, caindo num ponteiro liberado —
    // segfault dentro de QQmlTypeWrapper::lookupSingletonProperty, antes
    // de qualquer null-check nosso rodar. Foi assim que o control center
    // morreu num login.
    //
    // O rastreamento de dependências do QML é dinâmico: com o ramo falso,
    // nenhuma dependência é registrada e o notifier não tem o que
    // reavaliar. Dez segundos cobrem folgadamente a enumeração.
    //
    // Aqui o custo de um crash seria a barra INTEIRA — bar, notificações
    // e OSD dividem processo. Por isso o guarda é obrigatório, não
    // opcional.
    // ------------------------------------------------------------------
    property bool ready: false

    Timer {
        interval: 10000
        running: true
        onTriggered: root.ready = true
    }

    PwObjectTracker { objects: root.ready ? [Pipewire.defaultAudioSink] : [] }

    readonly property var sink: root.ready ? Pipewire.defaultAudioSink : null
    property bool showing: false

    // Só mostra em MUDANÇA. Sem isto o OSD pisca quando `ready` liga e
    // o Pipewire publica o valor corrente pela primeira vez.
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

    PanelWindow {
        anchors { bottom: true }
        margins.bottom: 160

        implicitWidth: 320
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
                font.pixelSize: Theme.fsCaption
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
                font.pixelSize: Theme.fsLabel
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
