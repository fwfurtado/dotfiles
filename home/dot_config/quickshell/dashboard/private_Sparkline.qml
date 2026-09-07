import QtQuick

// Sparkline com preenchimento. Ancorado à direita: amostras novas entram
// pela direita e o gráfico só se completa conforme o histórico cresce, em
// vez de esticar duas amostras pela largura toda.
Item {
    id: root

    property var values: []
    property int capacity: 60
    property real minValue: 0
    property real maxValue: 100
    property color stroke: Theme.accent
    property int gridLines: 3

    // Redesenha só quando chega amostra nova, não a cada frame.
    onValuesChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width, h = height
            var d = root.values
            var span = Math.max(0.0001, root.maxValue - root.minValue)

            ctx.strokeStyle = Theme.surfaceAlt
            ctx.lineWidth = 1
            for (var g = 1; g <= root.gridLines; g++) {
                var y = h - (h * g / (root.gridLines + 1))
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(w, y); ctx.stroke()
            }

            if (!d || d.length < 2) return

            function yOf(v) {
                var t = (v - root.minValue) / span
                return h - Math.max(0, Math.min(1, t)) * h
            }

            var step = w / (root.capacity - 1)
            var x0 = w - (d.length - 1) * step

            ctx.beginPath()
            ctx.moveTo(x0, yOf(d[0]))
            for (var i = 1; i < d.length; i++)
                ctx.lineTo(x0 + i * step, yOf(d[i]))

            ctx.strokeStyle = root.stroke
            ctx.lineWidth = 1.6
            ctx.stroke()

            ctx.lineTo(x0 + (d.length - 1) * step, h)
            ctx.lineTo(x0, h)
            ctx.closePath()
            ctx.fillStyle = Qt.rgba(root.stroke.r, root.stroke.g, root.stroke.b, 0.13)
            ctx.fill()
        }
    }
}
