import QtQuick

// Linha de lista: dispositivo de áudio, rede Wi-Fi, dispositivo Bluetooth.
Rectangle {
    id: root

    property string label: ""
    property string detail: ""
    property bool selected: false
    property bool busy: false

    signal activated()

    implicitHeight: 36
    radius: 8
    color: selected ? Theme.surfaceAlt
         : area.containsMouse ? Qt.rgba(Theme.surfaceAlt.r, Theme.surfaceAlt.g,
                                        Theme.surfaceAlt.b, 0.5)
         : "transparent"

    Rectangle {
        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
        width: 4; height: 4; radius: 2
        color: root.selected ? Theme.accent : "transparent"
    }

    Text {
        id: name
        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
        width: Math.min(implicitWidth, root.width - 100)
        text: root.label
        font.family: Theme.mono
        font.pixelSize: Theme.fsStrong
        color: root.selected ? Theme.text : Theme.muted
        elide: Text.ElideRight
    }

    Text {
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        text: root.busy ? "…" : root.detail
        font.family: Theme.mono
        font.pixelSize: Theme.fsBody
        color: Theme.muted
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
