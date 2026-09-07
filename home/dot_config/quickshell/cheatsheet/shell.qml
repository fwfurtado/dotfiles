import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Fuzzy.js" as Fuzzy

// Cheatsheet de binds. Processo separado do bar.
//   qs -c cheatsheet ipc call cheatsheet toggle
//
// A description carrega estrutura, separada por "::":
//
//   description                        -> grupo "other"
//   group::description                 -> seção
//   group::subgroup::description       -> seção + sub-seção
//
// Binds dentro de um submap que não declaram subgroup herdam o nome do
// submap como sub-seção. Assim o modo `resize` mora dentro de `window`
// em vez de virar um grupo de topo isolado.
ShellRoot {
    id: root

    property var binds: []
    property var results: []       // achatado: kind = group | sub | bind
    property bool open: false

    readonly property int colKey: 300
    readonly property int colAction: 440
    readonly property string fallbackGroup: "other"

    IpcHandler {
        target: "cheatsheet"
        function toggle(): void { root.open ? root.close() : root.show() }
        function show(): void { root.show() }
        function close(): void { root.close() }
    }

    function show() {
        loader.running = true
        root.open = true
    }

    function close() { root.open = false }

    function decodeMods(m) {
        var out = ""
        if (m & 64) out += "SUPER+"
        if (m & 8)  out += "ALT+"
        if (m & 4)  out += "CTRL+"
        if (m & 1)  out += "SHIFT+"
        return out
    }

    Process {
        id: loader
        command: ["hyprctl", "-j", "binds"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parsed = []
                try {
                    var raw = JSON.parse(this.text)
                    for (var i = 0; i < raw.length; i++) {
                        var b = raw[i]
                        if (!b.dispatcher) continue

                        var submap = b.submap && b.submap.length > 0 ? b.submap : ""
                        var combo = root.decodeMods(b.modmask) + b.key
                        var action = b.dispatcher + (b.arg ? " " + b.arg : "")

                        // group :: subgroup :: description
                        var group = ""
                        var sub = ""
                        var desc = ""
                        var parts = (b.description || "").split("::")
                        for (var p = 0; p < parts.length; p++) parts[p] = parts[p].trim()
                        if (parts.length >= 3) {
                            group = parts[0]
                            sub = parts[1]
                            desc = parts.slice(2).join("::")
                        } else if (parts.length === 2) {
                            group = parts[0]
                            desc = parts[1]
                        } else {
                            desc = parts[0]
                        }

                        if (submap.length > 0 && sub.length === 0) sub = submap
                        if (group.length === 0) group = root.fallbackGroup

                        var described = desc.length > 0

                        // `bindm` vira dispatcher `mouse` com o nome real no
                        // arg. `hyprctl dispatch mouse movewindow` não é uma
                        // chamada válida — espera prefixo de estado (1/0).
                        // Estes binds são documentação, não ação.
                        var runnable = b.dispatcher !== "mouse"

                        parsed.push({
                            kind: "bind",
                            combo: combo,
                            group: group,
                            sub: sub,
                            submap: submap,
                            disp: b.dispatcher,
                            arg: b.arg || "",
                            label: described ? desc : action,
                            action: action,
                            described: described,
                            runnable: runnable,
                            order: parsed.length,
                            haystack: group + "  " + (sub ? sub + "  " : "")
                                + combo + "  "
                                + (described ? desc + "  " : "")
                                + action
                        })
                    }
                } catch (e) {
                    console.warn("cheatsheet: hyprctl binds ilegível:", e)
                }
                root.binds = parsed
                root.refilter()
            }
        }
    }

    // Melhor score e menor posição-no-arquivo de um balde. Score decide a
    // ordem quando há busca; com a busca vazia todos empatam em zero e a
    // ordem do config — que já é significativa — desempata.
    function rank(items) {
        var best = -Infinity, first = Infinity
        for (var i = 0; i < items.length; i++) {
            if (items[i]._score > best) best = items[i]._score
            if (items[i].order < first) first = items[i].order
        }
        return { score: best, order: first }
    }

    function byRank(ra, rb) {
        return ra.score !== rb.score ? rb.score - ra.score : ra.order - rb.order
    }

    // Filtra, agrupa em dois níveis e achata numa lista com cabeçalhos.
    // ListView.section só funciona com roles nomeados; com array JS o
    // delegate só enxerga modelData, então os cabeçalhos entram como itens
    // de verdade e a navegação os pula.
    function refilter() {
        var matched = Fuzzy.filter(root.binds, search.text, function (b) { return b.haystack })

        var groups = {}
        var gorder = []
        for (var i = 0; i < matched.length; i++) {
            var m = matched[i]
            if (!groups[m.group]) {
                groups[m.group] = { subs: {}, sorder: [], total: 0 }
                gorder.push(m.group)
            }
            var g = groups[m.group]
            if (!g.subs[m.sub]) { g.subs[m.sub] = []; g.sorder.push(m.sub) }
            g.subs[m.sub].push(m)
            g.total++
        }

        for (var k = 0; k < gorder.length; k++) {
            var gg = groups[gorder[k]]
            gg.ranks = {}
            for (var s = 0; s < gg.sorder.length; s++) {
                var name = gg.sorder[s]
                gg.subs[name].sort(function (a, b) {
                    return a._score !== b._score ? b._score - a._score : a.order - b.order
                })
                gg.ranks[name] = root.rank(gg.subs[name])
            }
            // Sem subgrupo ("") sempre antes dos subgrupos: são os binds
            // diretos da seção, e enfiá-los depois de uma sub-seção seria
            // ambíguo sobre a qual pertencem.
            gg.sorder.sort(function (a, b) {
                if ((a === "") !== (b === "")) return a === "" ? -1 : 1
                return root.byRank(gg.ranks[a], gg.ranks[b])
            })
            gg.rank = root.rank(matched.filter(function (x) { return x.group === gorder[k] }))
        }

        gorder.sort(function (a, b) { return root.byRank(groups[a].rank, groups[b].rank) })

        var flat = []
        for (var gi = 0; gi < gorder.length; gi++) {
            var gname = gorder[gi]
            var grp = groups[gname]
            flat.push({ kind: "group", title: gname, count: grp.total, first: gi === 0 })
            for (var si = 0; si < grp.sorder.length; si++) {
                var sname = grp.sorder[si]
                if (sname.length > 0)
                    flat.push({ kind: "sub", title: sname, count: grp.subs[sname].length })
                var items = grp.subs[sname]
                for (var ii = 0; ii < items.length; ii++) flat.push(items[ii])
            }
        }

        root.results = flat
        table.currentIndex = root.firstBind()
        if (table.currentIndex >= 0) table.positionViewAtBeginning()
    }

    function firstBind() {
        for (var i = 0; i < root.results.length; i++)
            if (root.results[i].kind === "bind") return i
        return -1
    }

    // Anda para o próximo item selecionável, pulando cabeçalhos e dando volta.
    function step(dir) {
        var n = root.results.length
        if (n === 0) return
        var i = table.currentIndex
        for (var k = 0; k < n; k++) {
            i += dir
            if (i < 0) i = n - 1
            else if (i >= n) i = 0
            if (root.results[i].kind === "bind") {
                table.currentIndex = i
                table.positionViewAtIndex(i, ListView.Contain)
                return
            }
        }
    }

    function current() {
        var i = table.currentIndex
        if (i < 0 || i >= root.results.length) return null
        return root.results[i].kind === "bind" ? root.results[i] : null
    }

    function run(item) {
        if (!item || !item.runnable) return
        root.close()
        dispatch.command = item.arg.length > 0
            ? ["hyprctl", "dispatch", item.disp, item.arg]
            : ["hyprctl", "dispatch", item.disp]
        dispatch.running = true
    }

    Process { id: dispatch }

    PanelWindow {
        visible: root.open

        implicitWidth: 1200
        implicitHeight: 700

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-cheatsheet"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: if (visible) {
            search.text = ""
            search.input.forceActiveFocus()
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            SearchField {
                id: search
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.topMargin: 18

                onTextChanged: root.refilter()
                onCancelled: root.close()
                onAccepted: root.run(root.current())
                onMoveDown: root.step(1)
                onMoveUp: root.step(-1)
            }

            Rectangle {
                id: sep
                anchors { left: parent.left; right: parent.right; top: search.bottom }
                anchors.topMargin: 16
                height: 1
                color: Theme.border
            }

            // ---------------- componentes de linha ----------------

            Component {
                id: groupRow

                Item {
                    Rectangle {
                        anchors {
                            left: parent.left; right: parent.right
                            bottom: title.top; bottomMargin: 8
                            leftMargin: 12; rightMargin: 12
                        }
                        visible: !entry.first
                        height: 1
                        color: Theme.border
                    }

                    Text {
                        id: title
                        anchors { left: parent.left; leftMargin: 12; bottom: parent.bottom; bottomMargin: 6 }
                        text: entry.title.toUpperCase()
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsBody
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: Theme.accent
                    }

                    Text {
                        anchors { left: title.right; leftMargin: 10; baseline: title.baseline }
                        text: entry.count
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsBody
                        color: Theme.muted
                    }
                }
            }

            Component {
                id: subRow

                Item {
                    Text {
                        id: subTitle
                        anchors { left: parent.left; leftMargin: 28; bottom: parent.bottom; bottomMargin: 4 }
                        text: entry.title
                        font.family: Theme.mono
                        font.pixelSize: Theme.fsBody
                        font.letterSpacing: 0.5
                        font.italic: true
                        color: Theme.muted
                    }

                    // Fio ligando o rótulo à margem: sinaliza aninhamento sem
                    // gastar indentação, que já é escassa na coluna da tecla.
                    Rectangle {
                        anchors {
                            left: subTitle.right; leftMargin: 10
                            right: parent.right; rightMargin: 12
                            verticalCenter: subTitle.verticalCenter
                        }
                        height: 1
                        color: Theme.border
                    }
                }
            }

            Component {
                id: bindRow

                Rectangle {
                    readonly property bool focused: idx === table.currentIndex

                    radius: 6
                    color: focused ? Theme.surfaceAlt : "transparent"

                    // Barra de foco: fundo sozinho não basta num painel escuro.
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        anchors.margins: 4
                        width: 2; radius: 1
                        visible: parent.focused
                        color: entry.runnable ? Theme.accent : Theme.muted
                    }

                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        anchors.leftMargin: entry.sub.length > 0 ? 28 : 12
                        width: root.colKey - anchors.leftMargin
                        text: Fuzzy.highlightQuery(search.text, entry.combo)
                        textFormat: Text.RichText
                        font.family: Theme.mono; font.pixelSize: Theme.fsLead
                        color: entry.runnable ? Theme.accent : Theme.muted
                        elide: Text.ElideRight
                    }

                    Text {
                        anchors { left: parent.left; leftMargin: 12 + root.colKey; verticalCenter: parent.verticalCenter }
                        width: root.colAction
                        text: Fuzzy.highlightQuery(search.text, entry.label)
                        textFormat: Text.RichText
                        font.family: Theme.mono; font.pixelSize: Theme.fsLead
                        color: entry.runnable ? Theme.text : Theme.muted
                        elide: Text.ElideRight
                    }

                    // Só quando há description — senão seria a mesma string
                    // repetida em duas colunas.
                    Text {
                        anchors {
                            left: parent.left; leftMargin: 12 + root.colKey + root.colAction + 16
                            right: parent.right; rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        visible: entry.described
                        text: entry.action
                        font.family: Theme.mono; font.pixelSize: Theme.fsStrong
                        color: Theme.muted
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: entry.runnable ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: table.currentIndex = idx
                        onClicked: root.run(entry)
                    }
                }
            }

            // ---------------- tabela ----------------

            ListView {
                id: table
                anchors { left: parent.left; right: parent.right; top: sep.bottom; bottom: footer.top }
                anchors.margins: 10
                clip: true

                model: root.results
                currentIndex: -1
                boundsBehavior: Flickable.StopAtBounds

                delegate: Loader {
                    required property var modelData
                    required property int index

                    // Nomes curtos para os componentes acima resolverem por escopo.
                    readonly property var entry: modelData
                    readonly property int idx: index

                    width: table.width
                    height: modelData.kind === "group"
                        ? (modelData.first ? 28 : 50)
                        : modelData.kind === "sub" ? 32 : 38

                    sourceComponent: modelData.kind === "group" ? groupRow
                        : modelData.kind === "sub" ? subRow : bindRow
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.results.length === 0
                text: root.binds.length === 0 ? "loading binds…" : "no match"
                font.family: Theme.mono; font.pixelSize: Theme.fsLead
                color: Theme.muted
            }

            Item {
                id: footer
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                anchors.margins: 14
                height: 16

                Text {
                    anchors { left: parent.left; leftMargin: 6 }
                    text: {
                        var n = 0
                        for (var i = 0; i < root.results.length; i++)
                            if (root.results[i].kind === "bind") n++
                        return n + " of " + root.binds.length
                    }
                    font.family: Theme.mono; font.pixelSize: Theme.fsBody
                    color: Theme.muted
                }

                Text {
                    anchors { right: parent.right; rightMargin: 6 }
                    text: "↑↓ navigate   ⏎ run   esc close"
                    font.family: Theme.mono; font.pixelSize: Theme.fsBody
                    color: Theme.muted
                }
            }
        }
    }
}
