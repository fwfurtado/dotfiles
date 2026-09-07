import QtQuick
import QtQuick.Shapes

// Ícones de linha desenhados. Ver controlcenter/Icon.qml para o porquê de
// não usar tema de ícones aqui e de nunca habilitar `layer.enabled`.
Item {
    id: root

    property string name: ""
    property int size: 20
    property color color: Theme.muted
    property real weight: 1.8

    implicitWidth: size
    implicitHeight: size

    readonly property var paths: ({
        "app":
            "M4 4 H10.5 V10.5 H4 Z M13.5 4 H20 V10.5 H13.5 Z " +
            "M4 13.5 H10.5 V20 H4 Z M13.5 13.5 H20 V20 H13.5 Z",

        "window":
            "M3 5 H21 V19 H3 Z M3 9 H21 M5.8 7 H6.8 M8.4 7 H9.4",

        "workspace":
            "M3.5 3.5 H10 V10 H3.5 Z M14 3.5 H20.5 V10 H14 Z " +
            "M3.5 14 H10 V20.5 H3.5 Z M14 14 H20.5 V20.5 H14 Z M15.6 16 H18.9",

        "keyboard":
            "M2.5 6.5 H21.5 V17.5 H2.5 Z " +
            "M6 10 H6.01 M9.5 10 H9.51 M13 10 H13.01 M16.5 10 H16.51 " +
            "M8 14 H16",

        "power":
            "M12 3 V11 M6.5 6.2 a8 8 0 1 0 11 0",

        "search":
            "M11 4 a7 7 0 1 0 0.01 0 M16.2 16.2 L21 21"
    })

    Shape {
        anchors.centerIn: parent
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.Center
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            fillColor: "transparent"
            strokeWidth: root.weight * (24 / root.size)
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg { path: root.paths[root.name] || "" }
        }
    }
}
