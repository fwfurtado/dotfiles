import QtQuick
import QtQuick.Layouts

// Card com cabeçalho (ícone + título à esquerda, valor de destaque à
// direita) e um slot de conteúdo. Existe para que o vocabulário visual
// dos três painéis seja definido num lugar só.
Rectangle {
    id: root

    default property alias content: body.data
    property string title: ""
    property string icon: ""
    property string value: ""
    property color valueColor: Theme.accent
    property int contentSpacing: 8
    property bool showHeader: true

    radius: 14
    color: Theme.base
    border.width: 1
    border.color: Theme.border

    implicitHeight: (showHeader ? header.height + 10 : 0) + body.implicitHeight + 28

    RowLayout {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: 14
        visible: root.showHeader
        height: visible ? 22 : 0
        spacing: 9

        Icon {
            visible: root.icon.length > 0
            name: root.icon
            size: 16
            color: Theme.muted
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            font.family: Theme.mono
            font.pixelSize: Theme.fsCaption
            font.letterSpacing: 0.5
            color: Theme.muted
            elide: Text.ElideRight
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            font.family: Theme.mono
            font.pixelSize: Theme.fsMetric
            font.weight: Font.DemiBold
            color: root.valueColor
        }
    }

    ColumnLayout {
        id: body
        anchors {
            left: parent.left; right: parent.right
            top: root.showHeader ? header.bottom : parent.top
            bottom: parent.bottom
        }
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: root.showHeader ? 10 : 14
        anchors.bottomMargin: 14
        spacing: root.contentSpacing
    }
}
