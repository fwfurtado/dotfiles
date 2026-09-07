//@ pragma IconTheme Yaru

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import "Fuzzy.js" as Fuzzy

// Launcher / omni menu. Um processo, dois modos — o modo vem pelo IPC:
//
//   qs -c omni ipc call omni apps    # só aplicações
//   qs -c omni ipc call omni all     # tudo
//
// Um config só em vez de dois diretórios: os dois menus compartilham
// código de verdade, não por symlink.
ShellRoot {
    id: root

    property bool open: false
    property string mode: "all"          // "apps" | "all"
    property var results: []
    property var bindItems: []

    // Aplicações e seus ícones são resolvidos UMA vez por abertura, não a
    // cada tecla. `resolveIcon` faz busca no tema de ícones; rodar isso
    // para dezenas de apps a cada keystroke é onde o campo começaria a
    // engasgar. Janelas e workspaces continuam vindo vivos — são poucos e
    // mudam enquanto o menu está aberto.
    property var appCache: []

    readonly property var order: ["app", "window", "workspace", "bind", "action"]

    IpcHandler {
        target: "omni"
        function apps(): void { root.show("apps") }
        function all(): void { root.show("all") }
        function toggle(): void { root.open ? root.close() : root.show("all") }
        function close(): void { root.close() }

        // Diagnóstico do tema de ícones. Não abre o menu; só imprime o que
        // o Quickshell resolve para um nome:
        //   qs -c omni ipc call omni probeIcon firefox
        function probeIcon(name: string): string {
            var raw = ""
            try { raw = Quickshell.iconPath(name, true) }
            catch (e) { return "iconPath falhou: " + e }
            return raw.length > 0
                ? "ok: " + raw
                : "não resolvido (tema de ícones vazio ou nome ausente)"
        }
    }

    function show(m) {
        // Clicar no mesmo bind duas vezes fecha; trocar de modo com o menu
        // aberto troca o modo em vez de fechar.
        if (root.open && root.mode === m) { root.close(); return }
        root.mode = m
        root.appCache = Sources.apps()
        if (m === "all") loadBinds.running = true
        root.open = true
    }

    function close() { root.open = false }

    // Binds vêm de um processo, então são carregados na abertura e ficam
    // em cache até a próxima. As outras fontes são objetos vivos.
    Process {
        id: loadBinds
        command: ["hyprctl", "-j", "binds"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.bindItems = Sources.binds(JSON.parse(this.text))
                } catch (e) {
                    root.bindItems = []
                    console.warn("omni: hyprctl binds ilegível:", e)
                }
                root.refilter()
            }
        }
    }

    function collect() {
        if (root.mode === "apps") return root.appCache
        return root.appCache
            .concat(Sources.windows())
            .concat(Sources.workspaces())
            .concat(root.bindItems)
            .concat(Sources.actions())
    }

    // Filtra, agrupa por tipo e achata com cabeçalhos intercalados.
    // ListView.section só funciona com roles nomeados; com array JS o
    // delegate só enxerga modelData, então os cabeçalhos entram como itens
    // e a navegação os pula.
    function refilter() {
        var pool = root.collect()
        for (var i = 0; i < pool.length; i++) pool[i].order = i

        var matched = Fuzzy.filter(pool, search.text, function (x) { return x.haystack })

        var buckets = {}
        for (var m = 0; m < matched.length; m++) {
            var t = matched[m].type
            if (!buckets[t]) buckets[t] = []
            buckets[t].push(matched[m])
        }

        var flat = []
        var first = true
        for (var k = 0; k < root.order.length; k++) {
            var type = root.order[k]
            var items = buckets[type]
            if (!items || items.length === 0) continue

            items.sort(function (a, b) {
                return a._score !== b._score ? b._score - a._score : a.order - b.order
            })

            // Sem cabeçalho no modo apps: com uma fonte só, a seção não
            // informa nada e rouba uma linha da lista.
            if (root.mode !== "apps") {
                flat.push({
                    kind: "header",
                    type: type,
                    label: Sources.kinds[type].label,
                    count: items.length,
                    first: first
                })
                first = false
            }

            var cap = root.mode === "apps" ? items.length : 6
            for (var n = 0; n < Math.min(cap, items.length); n++) flat.push(items[n])

            // Corta cada seção em 6 no modo omni: cinco fontes sem limite
            // enterrariam janelas e ações sob cem aplicações.
            if (root.mode !== "apps" && items.length > cap) {
                flat.push({
                    kind: "more",
                    label: "+ " + (items.length - cap) + " more in " + Sources.kinds[type].label
                })
            }
        }

        root.results = flat
        list.currentIndex = root.firstItem()
        if (list.currentIndex >= 0) list.positionViewAtBeginning()
    }

    function firstItem() {
        for (var i = 0; i < root.results.length; i++)
            if (root.results[i].kind === "item") return i
        return -1
    }

    function step(dir) {
        var n = root.results.length
        if (n === 0) return
        var i = list.currentIndex
        for (var k = 0; k < n; k++) {
            i += dir
            if (i < 0) i = n - 1
            else if (i >= n) i = 0
            if (root.results[i].kind === "item") {
                list.currentIndex = i
                list.positionViewAtIndex(i, ListView.Contain)
                return
            }
        }
    }

    function current() {
        var i = list.currentIndex
        if (i < 0 || i >= root.results.length) return null
        return root.results[i].kind === "item" ? root.results[i] : null
    }

    Process { id: runner }

    // Despacho por tipo, não por closure guardada no modelo: closure em
    // array de modelo funciona, mas some no primeiro refilter e o bug fica
    // difícil de ver.
    function run(item) {
        if (!item) return
        root.close()

        try {
            if (item.type === "app") {
                item.entry.execute()
            } else if (item.type === "window") {
                item.toplevel.activate()
            } else if (item.type === "workspace") {
                Hyprland.dispatch("workspace " + item.workspaceId)
            } else if (item.type === "bind") {
                Hyprland.dispatch(item.dispatcher
                    + (item.arg.length > 0 ? " " + item.arg : ""))
            } else if (item.type === "action") {
                runner.command = item.command
                runner.running = true
            }
        } catch (e) {
            console.warn("omni: falha ao executar", item.type, item.label, e)
        }
    }

    PanelWindow {
        visible: root.open

        anchors { top: true; bottom: true; left: true; right: true }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-omni"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: if (visible) {
            search.text = ""
            root.refilter()
            search.input.forceActiveFocus()
        }

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: root.close()
            }

            Rectangle {
                id: card

                // Um pouco acima do centro vertical: o olhar repousa acima
                // do meio geométrico, e num painel de 1440px de altura o
                // centro exato parece baixo.
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Math.round(parent.height * 0.16)

                width: 760
                height: 560

                radius: 16
                color: Theme.surface
                border.width: 1
                border.color: Theme.border

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: (e) => e.accepted = true
                }

                SearchField {
                    id: search
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    anchors.margins: 14

                    placeholder: root.mode === "apps"
                        ? "search applications…"
                        : "search apps, windows, workspaces, keys…"

                    onTextChanged: root.refilter()
                    onCancelled: root.close()
                    onAccepted: root.run(root.current())
                    onMoveDown: root.step(1)
                    onMoveUp: root.step(-1)
                }

                Rectangle {
                    id: sep
                    anchors { left: parent.left; right: parent.right; top: search.bottom }
                    anchors.topMargin: 12
                    height: 1
                    color: Theme.border
                }

                // ---------------- delegates ----------------

                Component {
                    id: headerRow

                    Item {
                        Rectangle {
                            anchors {
                                left: parent.left; right: parent.right
                                bottom: title.top; bottomMargin: 7
                                leftMargin: 14; rightMargin: 14
                            }
                            visible: !entry.first
                            height: 1
                            color: Theme.border
                        }

                        Icon {
                            id: glyph
                            anchors {
                                left: parent.left; leftMargin: 14
                                verticalCenter: title.verticalCenter
                            }
                            name: Sources.kinds[entry.type].icon
                            size: 14
                            color: Theme.accent
                        }

                        Text {
                            id: title
                            anchors {
                                left: glyph.right; leftMargin: 10
                                bottom: parent.bottom; bottomMargin: 6
                            }
                            text: entry.label.toUpperCase()
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsLabel
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.5
                            color: Theme.accent
                        }

                        Text {
                            anchors { left: title.right; leftMargin: 10; baseline: title.baseline }
                            text: entry.count
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsLabel
                            color: Theme.muted
                        }
                    }
                }

                Component {
                    id: moreRow

                    Item {
                        Text {
                            anchors { left: parent.left; leftMargin: 38; verticalCenter: parent.verticalCenter }
                            text: entry.label
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsLabel
                            font.italic: true
                            color: Theme.border
                        }
                    }
                }

                Component {
                    id: itemRow

                    Rectangle {
                        id: row
                        readonly property bool focused: idx === list.currentIndex

                        radius: 9
                        color: focused ? Theme.surfaceAlt : "transparent"

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                            anchors.margins: 5
                            width: 2; radius: 1
                            visible: row.focused
                            color: Theme.accent
                        }

                        // Ícone real do tema quando existe; o desenho da
                        // categoria como fallback. Os dois ocupam a mesma
                        // caixa, então a coluna de texto não desalinha entre
                        // linhas com e sem ícone.
                        Item {
                            id: kindIcon
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            width: 22
                            height: 22

                            readonly property string art: entry.art || ""

                            Image {
                                anchors.fill: parent
                                visible: kindIcon.art.length > 0
                                source: kindIcon.art
                                // sourceSize evita decodificar um SVG na
                                // resolução nativa para exibir a 22px.
                                sourceSize.width: 44
                                sourceSize.height: 44
                                smooth: true
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Icon {
                                anchors.centerIn: parent
                                visible: kindIcon.art.length === 0
                                name: Sources.kinds[entry.type].icon
                                size: 18
                                color: row.focused ? Theme.accent : Theme.muted
                            }
                        }

                        Text {
                            id: name
                            anchors {
                                left: kindIcon.right; leftMargin: 14
                                verticalCenter: parent.verticalCenter
                            }
                            width: Math.min(implicitWidth, 400)
                            text: Fuzzy.highlightQuery(search.text, entry.label)
                            textFormat: Text.RichText
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsLead
                            color: Theme.text
                            elide: Text.ElideRight
                        }

                        Text {
                            anchors {
                                left: name.right; leftMargin: 14
                                right: parent.right; rightMargin: 16
                                verticalCenter: parent.verticalCenter
                            }
                            horizontalAlignment: Text.AlignRight
                            text: entry.detail
                            font.family: Theme.mono
                            font.pixelSize: Theme.fsCaption
                            color: Theme.muted
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: list.currentIndex = idx
                            onClicked: root.run(entry)
                        }
                    }
                }

                // ---------------- lista ----------------

                ListView {
                    id: list
                    anchors {
                        left: parent.left; right: parent.right
                        top: sep.bottom; bottom: footer.top
                    }
                    anchors.margins: 10
                    clip: true

                    model: root.results
                    currentIndex: -1
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Loader {
                        required property var modelData
                        required property int index

                        readonly property var entry: modelData
                        readonly property int idx: index

                        width: list.width
                        height: modelData.kind === "header"
                            ? (modelData.first ? 26 : 42)
                            : modelData.kind === "more" ? 22 : 38

                        sourceComponent: modelData.kind === "header" ? headerRow
                            : modelData.kind === "more" ? moreRow : itemRow
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.results.length === 0
                    text: "no match"
                    font.family: Theme.mono; font.pixelSize: Theme.fsStrong
                    color: Theme.muted
                }

                Item {
                    id: footer
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    anchors.margins: 16
                    height: 18

                    Text {
                        anchors { left: parent.left; leftMargin: 6 }
                        text: {
                            var n = 0
                            for (var i = 0; i < root.results.length; i++)
                                if (root.results[i].kind === "item") n++
                            return root.mode === "apps"
                                ? n + " applications" : n + " results"
                        }
                        font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                        color: Theme.muted
                    }

                    Text {
                        anchors { right: parent.right; rightMargin: 6 }
                        text: "↑↓ navigate   ⏎ run   esc close"
                        font.family: Theme.mono; font.pixelSize: Theme.fsLabel
                        color: Theme.muted
                    }
                }
            }
        }
    }
}
