import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Servidor de notificação + popups. Substitui o mako inteiro.
//
// Posicionadas à DIREITA, alinhadas com a ilha de sistema. Notificação no
// canto oposto ao que você estava olhando, num monitor de 5120px, é
// notificação que você não lê.
Scope {
    id: root

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: (notif) => {
            notif.tracked = true
        }
    }

    PanelWindow {
        anchors { top: true; right: true }
        margins {
            top: Theme.topMargin + Theme.islandHeight + Theme.gap
            right: Theme.sideMargin
        }

        implicitWidth: 460
        implicitHeight: Math.max(1, column.implicitHeight)
        visible: server.trackedNotifications.values.length > 0

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: Theme.gap

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: body.implicitHeight + 28

                    color: Theme.surface
                    radius: Theme.islandRadius
                    border.width: 1
                    border.color: modelData.urgency === NotificationUrgency.Critical
                        ? Theme.alert : Theme.border

                    // Barra de urgência, não ícone. Cor codifica severidade;
                    // ícone de app não diz nada que o título já não diga.
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        anchors.margins: 1
                        width: 4
                        radius: 2
                        color: card.modelData.urgency === NotificationUrgency.Critical
                            ? Theme.alert
                            : card.modelData.urgency === NotificationUrgency.Low
                              ? Theme.muted : Theme.accent
                    }

                    ColumnLayout {
                        id: body
                        anchors.fill: parent
                        anchors.margins: 14
                        anchors.leftMargin: 20
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: card.modelData.appName
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsCaption
                            font.letterSpacing: 0.5
                            color: Theme.muted
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: card.modelData.summary
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsStrong
                            font.weight: Font.DemiBold
                            color: Theme.text
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: card.modelData.body.length > 0
                            text: card.modelData.body
                            textFormat: Text.MarkdownText
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsBody
                            color: Theme.muted
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.modelData.dismiss()
                    }

                    // Auto-dismiss. Crítica não some sozinha.
                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: card.modelData.expireTimeout > 0
                            ? card.modelData.expireTimeout * 1000 : 6000
                        onTriggered: card.modelData.expire()
                    }

                    opacity: 0
                    Component.onCompleted: opacity = 1
                    Behavior on opacity {
                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
