import QtQuick

// Botão só de ícone. O rótulo não some — ele migra para a linha de dica
// da fileira, exposta via `hovered`. Ícone sem rótulo algum obriga a
// decorar o desenho; ícone com dica sob demanda mantém a densidade e
// ainda responde "o que é isto?".
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    property bool armed: false
    property bool enabled: true
    property color accent: Theme.accent

    readonly property bool hovered: area.containsMouse

    signal activated()

    implicitHeight: 44
    radius: 10

    color: armed ? Theme.alert
         : active ? Theme.surfaceAlt
         : area.containsMouse ? Theme.base
         : "transparent"
    border.width: 1
    border.color: armed ? Theme.alert
                : active ? root.accent
                : area.containsMouse ? Theme.border
                : Theme.border
    opacity: enabled ? 1 : 0.35

    Behavior on color { ColorAnimation { duration: 110 } }
    Behavior on border.color { ColorAnimation { duration: 110 } }
    Behavior on opacity { NumberAnimation { duration: 110 } }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: 22
        color: root.armed ? Theme.base
             : root.active ? root.accent
             : area.containsMouse ? Theme.text
             : Theme.muted
        Behavior on color { ColorAnimation { duration: 110 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
