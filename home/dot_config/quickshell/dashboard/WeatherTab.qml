import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Clima via wttr.in — sem chave de API. O formato j1 traz condição atual e
// três dias de previsão num JSON só.
//
// Cidade fixa, não auto-IP: o wttr.in resolve localização pelo IP quando
// você não passa cidade, e você roda sing-box com TUN interceptando tudo.
// Dependendo da saída, viria o clima de outro continente.
Item {
    id: root

    property bool panelOpen: false
    readonly property string location: "Sao Paulo"
    readonly property int refreshMinutes: 30

    property var current: null
    property var forecast: []
    property string status: "loading…"
    property date fetchedAt: new Date(0)

    function stale() {
        return (new Date() - root.fetchedAt) > root.refreshMinutes * 60000
    }

    onPanelOpenChanged: if (panelOpen && stale()) fetch.running = true
    Component.onCompleted: fetch.running = true

    Timer {
        interval: root.refreshMinutes * 60000
        running: true
        repeat: true
        onTriggered: fetch.running = true
    }

    // Ícone a partir do weatherCode do wttr.in. Códigos agrupados em quatro
    // famílias — o conjunto tem 40 valores e distinguir "chuvisco fraco" de
    // "chuvisco moderado" por desenho não muda decisão nenhuma.
    function iconFor(code) {
        var c = parseInt(code)
        if (isNaN(c)) return "cloud"
        if (c === 113) return "sun"
        if (c === 116 || c === 119 || c === 122 || c === 143 || c === 248 || c === 260)
            return "cloud"
        return "rain"
    }

    Process {
        id: fetch
        command: ["curl", "-sS", "--max-time", "10",
                  "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var j = JSON.parse(this.text)
                    var c = j.current_condition[0]
                    root.current = {
                        temp: c.temp_C,
                        feels: c.FeelsLikeC,
                        desc: c.weatherDesc[0].value,
                        code: c.weatherCode,
                        humidity: c.humidity,
                        wind: c.windspeedKmph,
                        windDir: c.winddir16Point,
                        pressure: c.pressure,
                        uv: c.uvIndex,
                        visibility: c.visibility
                    }
                    var days = []
                    for (var i = 0; i < Math.min(3, j.weather.length); i++) {
                        var d = j.weather[i]
                        // Índice 4 do array horário é ~12h: a leitura que
                        // representa o dia melhor que a das 00h.
                        var noon = d.hourly && d.hourly.length > 4 ? d.hourly[4] : null
                        days.push({
                            date: d.date,
                            min: d.mintempC,
                            max: d.maxtempC,
                            sun: d.astronomy && d.astronomy[0] ? d.astronomy[0].sunrise : "",
                            set: d.astronomy && d.astronomy[0] ? d.astronomy[0].sunset : "",
                            rain: noon ? noon.chanceofrain : "",
                            code: noon ? noon.weatherCode : "",
                            desc: noon ? noon.weatherDesc[0].value : ""
                        })
                    }
                    root.forecast = days
                    root.fetchedAt = new Date()
                    root.status = ""
                } catch (e) {
                    root.status = "invalid response from wttr.in"
                    console.warn("weather:", e)
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: if (this.text.length > 0) {
                root.status = "request failed"
                console.warn("weather (curl):", this.text)
            }
        }
    }

    component Field: ColumnLayout {
        id: fl
        property string label: ""
        property string value: ""
        spacing: 3
        Text {
            text: fl.label
            font.family: Theme.mono; font.pixelSize: Theme.fsLabel; font.letterSpacing: 0.5
            color: Theme.muted
        }
        Text {
            Layout.fillWidth: true
            text: fl.value
            font.family: Theme.mono; font.pixelSize: Theme.fsLead
            font.weight: Font.DemiBold
            color: Theme.text
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        visible: root.current !== null

        // ---------------- atual ----------------
        Card {
            Layout.fillWidth: true
            showHeader: false

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                ColumnLayout {
                    Layout.preferredWidth: 200
                    spacing: 4

                    Icon {
                        Layout.alignment: Qt.AlignHCenter
                        name: root.current ? root.iconFor(root.current.code) : "cloud"
                        size: 46
                        color: Theme.accent
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.current ? root.current.temp + "°" : ""
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsTemp
                        font.weight: Font.Light
                        color: Theme.text
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.current ? root.current.desc.toLowerCase() : ""
                        font.family: Theme.mono; font.pixelSize: Theme.fsStrong
                        color: Theme.muted
                        elide: Text.ElideRight
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    Text {
                        text: root.location.toLowerCase()
                        font.family: Theme.mono; font.pixelSize: Theme.fsLead
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 14
                        columnSpacing: 20

                        Field {
                            Layout.fillWidth: true
                            label: "FEELS LIKE"
                            value: root.current ? root.current.feels + "°" : "—"
                        }
                        Field {
                            Layout.fillWidth: true
                            label: "HUMIDITY"
                            value: root.current ? root.current.humidity + "%" : "—"
                        }
                        Field {
                            Layout.fillWidth: true
                            label: "WIND"
                            value: root.current
                                ? root.current.wind + " km/h " + root.current.windDir : "—"
                        }
                        Field {
                            Layout.fillWidth: true
                            label: "PRESSURE"
                            value: root.current ? root.current.pressure + " hPa" : "—"
                        }
                        Field {
                            Layout.fillWidth: true
                            label: "UV INDEX"
                            value: root.current ? root.current.uv : "—"
                        }
                        Field {
                            Layout.fillWidth: true
                            label: "SUNRISE / SUNSET"
                            value: root.forecast.length > 0
                                ? root.forecast[0].sun + " · " + root.forecast[0].set : "—"
                        }
                    }
                }
            }
        }

        // ---------------- previsão ----------------
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "calendar"
            title: "3-DAY FORECAST"

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Repeater {
                    model: root.forecast

                    Rectangle {
                        id: day
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 11
                        color: index === 0 ? Theme.surfaceAlt : "transparent"
                        border.width: 1
                        border.color: Theme.border

                        ColumnLayout {
                            anchors.centerIn: parent
                            width: parent.width - 16
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    var d = new Date(day.modelData.date + "T12:00:00")
                                    return day.index === 0 ? "today"
                                        : Qt.formatDate(d, "ddd dd/MM").toLowerCase()
                                }
                                font.family: Theme.mono; font.pixelSize: Theme.fsBody
                                font.weight: day.index === 0 ? Font.DemiBold : Font.Normal
                                color: day.index === 0 ? Theme.text : Theme.muted
                            }

                            Icon {
                                Layout.alignment: Qt.AlignHCenter
                                name: root.iconFor(day.modelData.code)
                                size: 32
                                color: Theme.accent
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8
                                Text {
                                    text: day.modelData.max + "°"
                                    font.family: Theme.mono; font.pixelSize: Theme.fsTitle
                                    font.weight: Font.DemiBold
                                    color: Theme.text
                                }
                                Text {
                                    text: day.modelData.min + "°"
                                    font.family: Theme.mono; font.pixelSize: Theme.fsTitle
                                    color: Theme.muted
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: day.modelData.desc.toLowerCase()
                                font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                                color: Theme.muted
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                visible: day.modelData.rain !== ""
                                text: day.modelData.rain + "% rain"
                                font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                                color: parseInt(day.modelData.rain) >= 50
                                    ? Theme.accent : Theme.muted
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: root.fetchedAt.getTime() > 0
                ? "updated " + Qt.formatDateTime(root.fetchedAt, "HH:mm") + " · wttr.in"
                : ""
            font.family: Theme.mono; font.pixelSize: Theme.fsLabel
            color: Theme.border
        }
    }

    // ---------------- estado sem dados ----------------
    ColumnLayout {
        anchors.centerIn: parent
        visible: root.current === null
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.status
            font.family: Theme.mono; font.pixelSize: Theme.fsBody
            color: Theme.muted
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            visible: root.status !== "loading…"
            implicitWidth: 120; implicitHeight: 34
            radius: 9
            color: retry.containsMouse ? Theme.surfaceAlt : "transparent"
            border.width: 1
            border.color: Theme.border

            Text {
                anchors.centerIn: parent
                text: "retry"
                font.family: Theme.mono; font.pixelSize: Theme.fsCaption
                color: Theme.muted
            }

            MouseArea {
                id: retry
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.status = "loading…"; fetch.running = true }
            }
        }
    }
}
