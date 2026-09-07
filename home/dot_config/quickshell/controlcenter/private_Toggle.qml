import QtQuick

// Interruptor deslizante. Substitui as pastilhas de texto ("wi-fi on",
// "ligado"), que descreviam o estado mas não pareciam acionáveis.
Item {
    id: root

    property bool checked: false
    property bool enabled: true
    property color onColor: Theme.good

    signal toggled()

    implicitWidth: 48
    implicitHeight: 27

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.onColor : Theme.surfaceAlt
        opacity: root.enabled ? 1 : 0.4
        border.width: 1
        border.color: root.checked ? root.onColor : Theme.border
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        id: knob
        width: parent.height - 6
        height: width
        radius: width / 2
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        // Contra o track aceso, o knob precisa ser a cor do fundo do painel
        // para ter contraste; apagado, ele é o elemento claro.
        color: root.checked ? Theme.base : Theme.muted
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
