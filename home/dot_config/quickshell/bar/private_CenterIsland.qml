import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

// Ilha central: tempo e mídia.
//
// Sem âncora horizontal: o layer-shell centraliza a surface na borda
// ancorada, e a janela se dimensiona pelo conteúdo. A `mask` garante que
// nada além da ilha visível engula clique.
PanelWindow {
    id: win

    anchors { top: true }
    margins.top: Theme.topMargin

    implicitWidth: island.implicitWidth
    implicitHeight: island.implicitHeight
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.islandHeight + Theme.topMargin

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    mask: Region { item: island }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property var player: Mpris.players.values.find(p => p.isPlaying)
        ?? Mpris.players.values[0] ?? null

    Process {
        id: dashboard
        command: ["qs", "-c", "dashboard", "ipc", "call", "dashboard", "toggle"]
    }

    // Área de clique da ilha inteira, IRMÃ de `island` e abaixo dela em z.
    // Dentro do Island ela viraria item do RowLayout e ocuparia espaço; e
    // com z menor, o MouseArea do título de mídia (que faz play/pause)
    // continua recebendo o clique dele primeiro.
    MouseArea {
        anchors.fill: island
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: dashboard.running = true
    }

    Island {
        id: island

        // Piso de largura: sem mídia tocando, a ilha teria só relógio e
        // data e ficaria estreita demais para ancorar o olhar no centro
        // de 5120px. Com mídia, ela cresce normalmente a partir daqui.
        minWidth: 300

        // --- Mídia (só aparece quando há algo tocando) ---
        Text {
            visible: win.player !== null && win.player.isPlaying
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight

            text: win.player
                ? "▶ " + (win.player.trackTitle || "") +
                  (win.player.trackArtist ? " · " + win.player.trackArtist : "")
                : ""
            font.family: Theme.mono
            font.pixelSize: Theme.fsBody
            color: Theme.muted

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (win.player) win.player.togglePlaying()
            }
        }

        Rectangle {
            visible: win.player !== null && win.player.isPlaying
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 1
            implicitHeight: 16
            color: Theme.border
        }

        // --- Relógio ---
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.family: Theme.mono
            font.pixelSize: Theme.fsTitle
            font.weight: Font.DemiBold
            color: Theme.text
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: Qt.formatDateTime(clock.date, "ddd dd MMM").toLowerCase()
            font.family: Theme.mono
            font.pixelSize: Theme.fsBody
            color: Theme.muted
        }
    }

    // -------------------------------------------------------------
    // Assinatura: fio de progresso da hora corrente.
    //
    // Num monitor desta largura você não olha para o relógio — ele está
    // fora do campo de leitura confortável. Mas você percebe uma barra
    // crescendo na periferia. O fio enche ao longo dos 60 minutos e
    // zera na virada da hora: consciência de tempo sem precisar ler
    // número nenhum.
    //
    // Declarado FORA do `Island`, não dentro. O Island tem
    // `default property alias content: layout.data`, então tudo escrito
    // dentro dele nasce filho do RowLayout — e o `parent: island` que
    // corrigia isso reparentava tarde demais para as âncoras, gerando
    // "Cannot anchor to an item that isn't a parent or sibling". Aqui
    // ele é irmão de `island` e ancorar a ele é legal.
    // -------------------------------------------------------------
    Rectangle {
        anchors.left: island.left
        anchors.right: island.right
        anchors.bottom: island.bottom
        anchors.leftMargin: Theme.islandRadius
        anchors.rightMargin: Theme.islandRadius
        anchors.bottomMargin: 4
        // 2px e não 1: a 1px o trilho some contra a superfície e só a
        // parte preenchida aparece, o que faz o fio parecer uma linha
        // solta encostada à esquerda em vez de uma barra de progresso.
        height: 2
        radius: 1
        color: Theme.surfaceAlt

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 2
            radius: 1
            width: parent.width *
                ((clock.date.getMinutes() * 60 + clock.date.getSeconds()) / 3600)
            color: Theme.accent
            opacity: 0.7

            Behavior on width {
                NumberAnimation { duration: 900; easing.type: Easing.Linear }
            }
        }
    }
}
