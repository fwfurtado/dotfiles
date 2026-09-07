import QtQuick
import QtQuick.Layouts
import Quickshell

// Calendário: hero com data e relógio, grade à esquerda, detalhe do dia
// selecionado à direita.
//
// Sem integração com iCal — isso exigiria daemon de polling, parser de
// RRULE e tratamento de timezone, que é projeto próprio e não uma aba.
// O painel da direita mostra o que dá para computar honestamente sobre o
// dia escolhido, em vez de um "No events" permanente.
Item {
    id: root

    property date cursor: {
        var n = new Date()
        return new Date(n.getFullYear(), n.getMonth(), 1)
    }
    property date selected: new Date()

    // Arrays explícitos em vez de Qt.formatDate: o formato depende do
    // locale do sistema, e o painel tem que ler igual independente de como
    // o LANG estiver naquele login.
    readonly property var weekdays: ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    readonly property var weekdayNames: [
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"]

    function longDate(d) {
        return root.weekdayNames[d.getDay()] + ", "
            + root.monthNames[d.getMonth()] + " " + d.getDate() + ", "
            + d.getFullYear()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function shift(months) {
        root.cursor = new Date(root.cursor.getFullYear(),
                               root.cursor.getMonth() + months, 1)
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate()
    }

    function isLeap(y) {
        return (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0
    }

    function dayOfYear(d) {
        return Math.floor((d - new Date(d.getFullYear(), 0, 1)) / 86400000) + 1
    }

    // Semana ISO: a quinta-feira da semana corrente define o ano.
    function isoWeek(d) {
        var th = new Date(d)
        th.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7))
        var jan4 = new Date(th.getFullYear(), 0, 4)
        return 1 + Math.round(
            ((th - jan4) / 86400000 - 3 + ((jan4.getDay() + 6) % 7)) / 7)
    }

    // Fase da lua: dias desde uma lua nova conhecida, módulo o mês
    // sinódico. Precisão de ~algumas horas, o que basta para nomear a fase.
    readonly property real synodic: 29.530588853
    function moonAge(d) {
        var epoch = Date.UTC(2000, 0, 6, 18, 14, 0)
        var a = ((d.getTime() - epoch) / 86400000) % root.synodic
        return a < 0 ? a + root.synodic : a
    }
    function moonName(age) {
        var p = age / root.synodic
        if (p < 0.02 || p >= 0.98) return "new moon"
        if (p < 0.24) return "waxing crescent"
        if (p < 0.26) return "first quarter"
        if (p < 0.49) return "waxing gibbous"
        if (p < 0.51) return "full moon"
        if (p < 0.74) return "waning gibbous"
        if (p < 0.76) return "last quarter"
        return "waning crescent"
    }

    // 42 células: 6 semanas cobrem qualquer mês, e a altura da grade fica
    // constante — sem o painel pulando de tamanho ao trocar de mês.
    readonly property var cells: {
        var out = []
        var start = new Date(root.cursor)
        start.setDate(1 - start.getDay())
        for (var i = 0; i < 42; i++) {
            var d = new Date(start)
            d.setDate(start.getDate() + i)
            out.push({
                date: d,
                day: d.getDate(),
                inMonth: d.getMonth() === root.cursor.getMonth()
            })
        }
        return out
    }

    // Filhos referenciam o id do componente, não `parent`: dentro de um
    // layout, `parent` é o que o layout decidir.
    component Stat: RowLayout {
        id: st
        property string label: ""
        property string value: ""
        Layout.fillWidth: true
        spacing: 10
        Text {
            Layout.fillWidth: true
            text: st.label
            font.family: Theme.mono; font.pixelSize: Theme.fsCaption
            color: Theme.muted
        }
        Text {
            text: st.value
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.text
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ---------------- hero: data + relógio ----------------
        Card {
            Layout.fillWidth: true
            showHeader: false

            // Data à esquerda, relógio encostado à direita — o par ancora
            // as duas pontas do card em vez de amontoar tudo no começo.
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: root.longDate(clock.date)
                    font.family: Theme.mono
                    font.pixelSize: Theme.fsHeading
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Item { Layout.fillWidth: true }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    font.family: Theme.mono
                    font.pixelSize: Theme.fsClock
                    font.weight: Font.Light
                    color: Theme.accent
                }

                Text {
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 9
                    text: Qt.formatDateTime(clock.date, "ss")
                    font.family: Theme.mono
                    font.pixelSize: Theme.fsHeading
                    color: Theme.muted
                }
            }
        }

        // ---------------- grade + detalhe ----------------
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Card {
                Layout.preferredWidth: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                showHeader: false
                contentSpacing: 12

                // navegação
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: root.monthNames[root.cursor.getMonth()] + " "
                            + root.cursor.getFullYear()
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsTitle
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Repeater {
                        model: [
                            { glyph: "chevron-left",  delta: -1 },
                            { glyph: "dot",           delta: 0  },
                            { glyph: "chevron-right", delta: 1  }
                        ]

                        Rectangle {
                            id: navBtn
                            required property var modelData

                            implicitWidth: 30
                            implicitHeight: 30
                            radius: 9
                            color: navArea.containsMouse ? Theme.surfaceAlt : "transparent"

                            Icon {
                                anchors.centerIn: parent
                                name: navBtn.modelData.glyph
                                size: 18
                                color: navArea.containsMouse ? Theme.accent : Theme.muted
                            }

                            MouseArea {
                                id: navArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (navBtn.modelData.delta === 0) {
                                        var n = new Date()
                                        root.cursor = new Date(n.getFullYear(), n.getMonth(), 1)
                                        root.selected = n
                                    } else {
                                        root.shift(navBtn.modelData.delta)
                                    }
                                }
                            }
                        }
                    }
                }

                // dias da semana
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: root.weekdays

                        Text {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsLabel
                            font.letterSpacing: 0.5
                            // Fim de semana em tom mais baixo: a grade ganha
                            // ritmo sem precisar de linha divisória.
                            color: (index === 0 || index === 6) ? Theme.border : Theme.muted
                        }
                    }
                }

                // grade
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 3
                    columnSpacing: 3

                    Repeater {
                        model: root.cells

                        Rectangle {
                            id: cell
                            required property var modelData

                            readonly property bool today: root.sameDay(modelData.date, clock.date)
                            readonly property bool picked: root.sameDay(modelData.date, root.selected)

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 9
                            color: today ? Theme.accent
                                 : picked ? Theme.surfaceAlt
                                 : cellArea.containsMouse ? Theme.surface : "transparent"
                            border.width: picked && !today ? 1 : 0
                            border.color: Theme.accent

                            Text {
                                anchors.centerIn: parent
                                text: cell.modelData.day
                                font.family: Theme.mono
                                font.pixelSize: Theme.fsStrong
                                font.weight: cell.today ? Font.DemiBold : Font.Normal
                                color: cell.today ? Theme.base
                                     : cell.modelData.inMonth ? Theme.text : Theme.border
                            }

                            MouseArea {
                                id: cellArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selected = cell.modelData.date
                            }
                        }
                    }
                }
            }

            // ---------------- detalhe do dia ----------------
            Card {
                Layout.preferredWidth: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "calendar"
                title: Qt.formatDate(root.selected, "dd/MM/yyyy")
                contentSpacing: 10

                Text {
                    Layout.fillWidth: true
                    text: root.weekdayNames[root.selected.getDay()]
                    font.family: Theme.mono
                    font.pixelSize: Theme.fsTitle
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                Stat {
                    label: "ISO week"
                    value: String(root.isoWeek(root.selected))
                }
                Stat {
                    label: "day of year"
                    value: root.dayOfYear(root.selected) + " / "
                        + (root.isLeap(root.selected.getFullYear()) ? 366 : 365)
                }
                Stat {
                    label: "left in month"
                    value: {
                        var last = new Date(root.selected.getFullYear(),
                                            root.selected.getMonth() + 1, 0).getDate()
                        return (last - root.selected.getDate()) + " days"
                    }
                }
                Stat {
                    label: "left in year"
                    value: {
                        var total = root.isLeap(root.selected.getFullYear()) ? 366 : 365
                        return (total - root.dayOfYear(root.selected)) + " days"
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Icon { name: "moon"; size: 20; color: Theme.accent }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: root.moonName(root.moonAge(root.selected))
                            font.family: Theme.mono; font.pixelSize: Theme.fsBody
                            color: Theme.text
                        }
                        Text {
                            text: root.moonAge(root.selected).toFixed(1) + " days into cycle"
                            font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                            color: Theme.muted
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.fillWidth: true
                    visible: !root.sameDay(root.selected, clock.date)
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        var a = new Date(root.selected.getFullYear(),
                                         root.selected.getMonth(), root.selected.getDate())
                        var b = new Date(clock.date.getFullYear(),
                                         clock.date.getMonth(), clock.date.getDate())
                        var n = Math.round((a - b) / 86400000)
                        return n > 0 ? "in " + n + " days" : n === 0 ? "" : (-n) + " days ago"
                    }
                    font.family: Theme.mono; font.pixelSize: Theme.fsCaption
                    color: Theme.muted
                }
            }
        }
    }
}
