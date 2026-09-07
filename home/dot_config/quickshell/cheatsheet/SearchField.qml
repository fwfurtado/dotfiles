import QtQuick

// Campo de busca. Lupa e "×" são desenhados com primitivas em vez de
// glifos: JetBrains Mono não tem U+2315, e depender de fallback de fonte
// para um ícone é o tipo de coisa que quebra em outra máquina.
Rectangle {
    id: root

    property alias text: input.text
    property alias input: input
    signal accepted()
    signal cancelled()
    signal moveDown()
    signal moveUp()
    signal moveLeft()
    signal moveRight()

    implicitHeight: 56
    radius: 13
    color: Theme.base
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.border

    Behavior on border.color { ColorAnimation { duration: 120 } }

    // --- Lupa ---
    Item {
        id: glass
        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
        width: 18; height: 18

        Rectangle {
            width: 13; height: 13; radius: 6.5
            anchors { left: parent.left; top: parent.top }
            color: "transparent"
            border.width: 1.5
            border.color: Theme.muted
            antialiasing: true
        }
        Rectangle {
            width: 5; height: 1.5
            anchors { right: parent.right; bottom: parent.bottom }
            anchors.rightMargin: 1; anchors.bottomMargin: 2
            rotation: 45
            color: Theme.muted
            antialiasing: true
        }
    }

    TextInput {
        id: input
        anchors {
            left: glass.right; leftMargin: 12
            right: clear.left; rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        height: 22

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
            text: "search binds…"
            color: Theme.muted
            font: input.font
        }

        Keys.onEscapePressed: root.cancelled()
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onDownPressed: root.moveDown()
        Keys.onUpPressed: root.moveUp()
        Keys.onLeftPressed: (e) => {
            // Só navega se o cursor já está no começo; senão é edição normal.
            if (input.cursorPosition === 0) { root.moveLeft(); e.accepted = true }
            else e.accepted = false
        }
        Keys.onRightPressed: (e) => {
            if (input.cursorPosition === input.text.length) { root.moveRight(); e.accepted = true }
            else e.accepted = false
        }
        Keys.onPressed: (e) => {
            if (e.modifiers & Qt.ControlModifier) {
                if (e.key === Qt.Key_N) { root.moveDown(); e.accepted = true }
                else if (e.key === Qt.Key_P) { root.moveUp(); e.accepted = true }
            }
        }
    }

    // --- Limpar ---
    Item {
        id: clear
        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
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
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { input.text = ""; input.forceActiveFocus() }
        }
    }
}
