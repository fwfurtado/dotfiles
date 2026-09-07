import QtQuick

// Campo de busca. Lupa desenhada com primitivas: JetBrains Mono não tem
// U+2315, e depender de fallback de fonte para um ícone é o tipo de coisa
// que quebra em outra máquina.
Rectangle {
    id: root

    property alias text: input.text
    property alias input: input
    property string placeholder: "search…"

    signal accepted()
    signal cancelled()
    signal moveDown()
    signal moveUp()

    implicitHeight: 56
    radius: 13
    color: Theme.base
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.border

    Behavior on border.color { ColorAnimation { duration: 120 } }

    Icon {
        id: glass
        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
        name: "search"
        size: 18
        color: Theme.muted
    }

    TextInput {
        id: input
        anchors {
            left: glass.right; leftMargin: 14
            right: clear.left; rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        height: 26

        color: Theme.text
        font.family: Theme.mono
        font.pixelSize: Theme.fsTitle
        selectionColor: Theme.accent
        selectedTextColor: Theme.base
        clip: true

        Text {
            anchors.fill: parent
            visible: input.text.length === 0
            verticalAlignment: Text.AlignVCenter
            text: root.placeholder
            color: Theme.muted
            font: input.font
        }

        Keys.onEscapePressed: root.cancelled()
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onDownPressed: root.moveDown()
        Keys.onUpPressed: root.moveUp()
        Keys.onPressed: (e) => {
            if (e.modifiers & Qt.ControlModifier) {
                if (e.key === Qt.Key_N) { root.moveDown(); e.accepted = true }
                else if (e.key === Qt.Key_P) { root.moveUp(); e.accepted = true }
                else if (e.key === Qt.Key_J) { root.moveDown(); e.accepted = true }
                else if (e.key === Qt.Key_K) { root.moveUp(); e.accepted = true }
            }
        }
    }

    Item {
        id: clear
        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
        width: 15; height: 15
        visible: input.text.length > 0

        Repeater {
            model: [45, -45]
            Rectangle {
                required property int modelData
                anchors.centerIn: parent
                width: 14; height: 1.6
                rotation: modelData
                color: clearArea.containsMouse ? Theme.text : Theme.muted
                antialiasing: true
            }
        }

        MouseArea {
            id: clearArea
            anchors.fill: parent
            anchors.margins: -7
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { input.text = ""; input.forceActiveFocus() }
        }
    }
}
