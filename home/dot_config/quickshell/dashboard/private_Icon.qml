import QtQuick
import QtQuick.Shapes

// Mesmo mecanismo do control center: traçados em viewBox 24x24, só stroke.
// Ver controlcenter/Icon.qml para o porquê de não usar tema de ícones e de
// não habilitar `layer.enabled` (ele rasteriza num FBO e escala a textura,
// o que borra).
Item {
    id: root

    property string name: ""
    property int size: 20
    property color color: Theme.muted
    property real weight: 1.8

    implicitWidth: size
    implicitHeight: size

    readonly property var paths: ({
        "calendar":
            "M3.5 6.5 H20.5 V20 H3.5 Z M3.5 10.5 H20.5 M8 4 V8 M16 4 V8",

        "cloud":
            "M7.5 18.5 a4.2 4.2 0 0 1 -0.4 -8.4 " +
            "a5.6 5.6 0 0 1 10.7 1.3 a3.6 3.6 0 0 1 -0.8 7.1 Z",

        "activity":
            "M2.5 13 H7 L9.5 6 L14 19 L16.5 13 H21.5",

        "cpu":
            "M7.5 7.5 H16.5 V16.5 H7.5 Z M4.5 4.5 H19.5 V19.5 H4.5 Z " +
            "M9.5 2 V4.5 M14.5 2 V4.5 M9.5 19.5 V22 M14.5 19.5 V22 " +
            "M2 9.5 H4.5 M2 14.5 H4.5 M19.5 9.5 H22 M19.5 14.5 H22",

        "memory":
            "M3 7 H21 V17 H3 Z M7 17 V20 M12 17 V20 M17 17 V20 " +
            "M7 10.5 V13.5 M12 10.5 V13.5 M17 10.5 V13.5",

        "disk":
            "M12 4 a8 8 0 1 0 0.01 0 M12 9.5 a2.5 2.5 0 1 0 0.01 0 " +
            "M13.8 13.8 L18 18",

        "thermometer":
            "M14 14.8 V5 a2 2 0 0 0 -4 0 V14.8 a4 4 0 1 0 4 0 Z",

        "clock":
            "M12 3 a9 9 0 1 0 0.01 0 M12 7 V12 L15.5 14",

        "moon":
            "M20 14.5 A8.5 8.5 0 1 1 9.5 4 a6.6 6.6 0 0 0 10.5 10.5 Z",

        "sun":
            "M12 8.2 a3.8 3.8 0 1 0 0.01 0 " +
            "M12 2 V4 M12 20 V22 M2 12 H4 M20 12 H22 " +
            "M4.9 4.9 l1.5 1.5 M17.6 17.6 l1.5 1.5 " +
            "M19.1 4.9 l-1.5 1.5 M6.4 17.6 l-1.5 1.5",

        "rain":
            "M7.5 15.5 a4.2 4.2 0 0 1 -0.4 -8.4 "
            + "a5.6 5.6 0 0 1 10.7 1.3 a3.6 3.6 0 0 1 -0.8 7.1 Z "
            + "M8.5 19 L7.5 21.5 M12 19 L11 21.5 M15.5 19 L14.5 21.5",

        "chevron-left":  "M14.5 5 L8 12 L14.5 19",
        "chevron-right": "M9.5 5 L16 12 L9.5 19",
        "dot":           "M12 11 a1.2 1.2 0 1 0 0.01 0"
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
