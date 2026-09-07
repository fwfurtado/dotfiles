import QtQuick
import QtQuick.Shapes

// Ícones de linha desenhados com PathSvg, não carregados de tema.
//
// Ícone simbólico do sistema (Adwaita/Yaru) é SVG monocromático pensado
// para ser recolorido pelo toolkit. O `Image` do Qt não recolore — viria
// escuro sobre fundo escuro. Resolver exigiria MultiEffect de colorização
// e uma dependência de tema instalado. Desenhado, segue o Theme sozinho.
//
// Todos os traçados vivem num viewBox 24x24 e são só stroke: um conjunto
// só de linhas fica coerente sem precisar acertar pesos de preenchimento.
Item {
    id: root

    property string name: ""
    property int size: 22
    property color color: Theme.muted
    property real weight: 1.8

    implicitWidth: size
    implicitHeight: size

    // Subcaminhos concatenados num `d` só — PathSvg aceita vários `M`,
    // o que evita ter que instanciar um ShapePath por traço.
    readonly property var paths: ({
        // --- seções ---
        "audio":
            "M3 9.5 H6.5 L11 6 V18 L6.5 14.5 H3 Z " +
            "M14.5 9.5 a4 4 0 0 1 0 5 " +
            "M17 7 a8 8 0 0 1 0 10",

        "network":
            "M2.5 8.5 a14 14 0 0 1 19 0 " +
            "M6 12 a9 9 0 0 1 12 0 " +
            "M9.5 15.5 a4.5 4.5 0 0 1 5 0 " +
            "M12 19.2 a0.6 0.6 0 1 0 0.01 0",

        "ethernet":
            "M3 9 H21 V17 H3 Z " +
            "M7 9 V6 H17 V9 " +
            "M7 13 V17 M12 13 V17 M17 13 V17",

        "bluetooth":
            "M8 7.5 L16 16.5 L12 20 V4 L16 7.5 L8 16.5",

        "display":
            "M12 8.2 a3.8 3.8 0 1 0 0.01 0 " +
            "M12 2 V4 M12 20 V22 M2 12 H4 M20 12 H22 " +
            "M4.9 4.9 l1.5 1.5 M17.6 17.6 l1.5 1.5 " +
            "M19.1 4.9 l-1.5 1.5 M6.4 17.6 l-1.5 1.5",

        // --- sessão ---
        // Cadeado fechado x cadeado com arco aberto para a direita: a
        // diferença precisa ser legível a 18px, então o arco do "sair"
        // sai bem para fora do corpo.
        "lock":
            "M5.5 10.5 H18.5 V20 H5.5 Z " +
            "M8.5 10.5 V7.5 a3.5 3.5 0 0 1 7 0 V10.5",

        "logout":
            "M13 4 H6 a2 2 0 0 0 -2 2 V18 a2 2 0 0 0 2 2 H13 " +
            "M16 8 L20 12 L16 16 M20 12 H9",

        "reboot":
            "M20 12 a8 8 0 1 1 -2.6 -5.9 " +
            "M20 4 V10 H14",

        "power":
            "M12 3 V11 " +
            "M6.5 6.2 a8 8 0 1 0 11 0",

        // --- presets de display ---
        // Sol cheio -> sol baixo -> lua -> lua com livro. A progressão é
        // visual: cada um tem menos "raio" que o anterior.
        "sun":
            "M12 8.2 a3.8 3.8 0 1 0 0.01 0 " +
            "M12 2 V4 M12 20 V22 M2 12 H4 M20 12 H22 " +
            "M4.9 4.9 l1.5 1.5 M17.6 17.6 l1.5 1.5 " +
            "M19.1 4.9 l-1.5 1.5 M6.4 17.6 l-1.5 1.5",

        "sunset":
            "M12 13 a4 4 0 0 1 8 0 M4 13 a4 4 0 0 1 4 -4 " +
            "M2 17 H22 " +
            "M12 3 V6 M5 6.5 l1.6 1.6 M19 6.5 l-1.6 1.6 " +
            "M12 9 a4 4 0 0 0 -4 4 H16 a4 4 0 0 0 -4 -4",

        "moon":
            "M20 14.5 A8.5 8.5 0 1 1 9.5 4 a6.6 6.6 0 0 0 10.5 10.5 Z",

        "book":
            "M4 5.5 H10 a2.5 2.5 0 0 1 2 2.5 a2.5 2.5 0 0 1 2 -2.5 H20 V18 H14 " +
            "a2 2 0 0 0 -2 1.5 a2 2 0 0 0 -2 -1.5 H4 Z " +
            "M12 8 V19.5",

        // --- ações ---
        "invert":
            "M12 3 a9 9 0 1 0 0.01 0 " +
            "M12 3 V21 a9 9 0 0 0 0 -18 Z",

        "reset":
            "M4 12 a8 8 0 1 0 2.6 -5.9 " +
            "M4 4 V10 H10",

        "check":
            "M5 12.5 L10 17.5 L19 6.5"
    })

    Shape {
        anchors.centerIn: parent
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.Center
        antialiasing: true

        // NÃO habilite `layer.enabled` aqui. Ele rasteriza a Shape num FBO
        // de 24x24 e depois escala a TEXTURA — reamostragem, ou seja,
        // borrão. Sem layer, a escala é aplicada na geometria antes da
        // rasterização e o traço sai nítido.
        //
        // CurveRenderer resolve as curvas no fragment shader, então o
        // resultado é independente de resolução. Se a build do Qt for
        // anterior ao 6.6 e reclamar desta linha, remova-a: com escala
        // para baixo o renderizador de geometria também fica aceitável.
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            fillColor: "transparent"
            // Compensa a escala para o traço final medir `weight` pixels
            // de tela. Sem isso, um 1.6 desenhado a 24 e exibido a 17 vira
            // 1.13px — abaixo de um pixel, o que o antialias transforma em
            // cinza claro em vez de linha.
            strokeWidth: root.weight * (24 / root.size)
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg { path: root.paths[root.name] || "" }
        }
    }
}
