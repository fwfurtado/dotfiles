import QtQuick
import QtQuick.Layouts

// Seção com ícone, cabeçalho, estado à direita e corpo expansível.
// Colapsada por padrão: o control center deve caber sem scroll no estado
// de repouso, e só a seção que você abriu ocupa espaço.
Rectangle {
    id: root

    default property alias body: content.data
    property string title: ""
    property string icon: ""
    property string status: ""
    property bool expanded: false
    property bool active: false
    property bool available: true
    property bool expandable: true

    signal toggled()

    Layout.fillWidth: true
    implicitHeight: header.height + (expanded ? content.implicitHeight + 14 : 0)
    Behavior on implicitHeight {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    radius: 12
    color: expanded ? Theme.base : "transparent"
    border.width: 1
    border.color: expanded ? Theme.border : "transparent"
    clip: true

    Item {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 52

        // O ícone carrega o estado pela cor: verde quando o recurso está
        // ativo, apagado quando não. Substitui a pastilha, em vez de
        // conviver com ela — dois indicadores do mesmo estado lado a lado
        // é ruído.
        Icon {
            id: glyph
            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
            name: root.icon
            size: 22
            color: !root.available ? Theme.border
                 : root.active ? Theme.good : Theme.muted
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            id: label
            anchors { left: glyph.right; leftMargin: 12; verticalCenter: parent.verticalCenter }
            text: root.title
            font.family: Theme.mono
            font.pixelSize: Theme.fsLead
            color: root.available ? Theme.text : Theme.border
        }

        Text {
            anchors {
                left: label.right; leftMargin: 12
                right: chevron.left; rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.AlignRight
            text: root.available ? root.status : "indisponível"
            font.family: Theme.mono
            font.pixelSize: Theme.fsStrong
            color: Theme.muted
            elide: Text.ElideRight
        }

        Text {
            id: chevron
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            visible: root.expandable && root.available
            text: "›"
            rotation: root.expanded ? 90 : 0
            font.family: Theme.mono
            font.pixelSize: Theme.fsTitle
            color: Theme.muted
            Behavior on rotation { NumberAnimation { duration: 150 } }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.available && root.expandable
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    ColumnLayout {
        id: content
        anchors {
            left: parent.left; right: parent.right; top: header.bottom
            leftMargin: 14; rightMargin: 14
        }
        spacing: 10
        opacity: root.expanded ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
}
