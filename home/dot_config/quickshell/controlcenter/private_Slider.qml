import QtQuick

// Slider próprio em vez de QtQuick.Controls: Controls arrasta um estilo
// inteiro e não combina com o resto, que é tudo primitiva.
Item {
    id: root

    property real value: 0          // 0..1
    property real step: 0.02
    property color fill: Theme.accent
    property bool enabled: true

    // Emitido em toda mudança vinda do usuário. Quem consome decide se
    // aplica na hora (Pipewire) ou com debounce (ddcutil, que é lento).
    signal moved(real value)

    implicitHeight: 22

    function setFrom(x) {
        var v = Math.max(0, Math.min(1, x / root.width))
        root.value = v
        root.moved(v)
    }

    Rectangle {
        id: track
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: 6
        radius: 3
        color: Theme.surfaceAlt

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: parent.width * Math.max(0, Math.min(1, root.value))
            radius: 3
            color: root.enabled ? root.fill : Theme.border
            Behavior on width {
                enabled: !area.pressed
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }
    }

    Rectangle {
        id: knob
        width: 14; height: 14; radius: 7
        anchors.verticalCenter: track.verticalCenter
        x: track.width * Math.max(0, Math.min(1, root.value)) - width / 2
        color: root.enabled ? root.fill : Theme.border
        border.width: 2
        border.color: Theme.surface
        visible: root.enabled
        Behavior on x {
            enabled: !area.pressed
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -6
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor

        onPressed: (e) => root.setFrom(e.x + anchors.margins)
        onPositionChanged: (e) => { if (pressed) root.setFrom(e.x + anchors.margins) }
        onWheel: (e) => {
            var v = Math.max(0, Math.min(1,
                root.value + (e.angleDelta.y > 0 ? root.step : -root.step)))
            root.value = v
            root.moved(v)
        }
    }
}
