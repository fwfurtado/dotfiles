pragma Singleton

import Quickshell
import QtQuick


Singleton {
    // Paleta "instrumento": aço frio sobre grafite. Um único acento, usado
    // com parcimônia — em 5120px de largura, cor demais vira poluição
    // periférica que você não consegue ignorar.
    readonly property color base:       "#12141a"
    readonly property color surface:    "#1b1f28"
    readonly property color surfaceAlt: "#232936"
    readonly property color border:     "#2a2f3a"
    readonly property color text:       "#c8cdd8"
    readonly property color muted:      "#6b7385"
    readonly property color accent:     "#7fb4c9"
    readonly property color alert:      "#d1735b"
    readonly property color good:       "#8fa876"

    readonly property string mono: "JetBrains Mono"

    // -----------------------------------------------------------------
    // Escala tipográfica
    //
    // Nomes semânticos, não números: `fsLabel` diz o papel do texto, `11`
    // não diz nada. Trocar o papel de um texto vira uma decisão explícita
    // em vez de um número ajustado no olho.
    //
    // Mudar `fontBase` move os seis primeiros degraus de uma vez. Os
    // tamanhos de exibição (relógio, temperatura) NÃO derivam dele de
    // propósito — eles são escolhas de composição, não pontos de uma
    // rampa, e escalar tudo junto quebraria a proporção.
    //
    // ATENÇÃO: isto centraliza o VALOR, não o layout. Alturas de linha,
    // larguras de coluna e tamanho de painel continuam literais nos
    // arquivos. Subir `fontBase` sem revisar essa geometria faz o texto
    // truncar — o `colKey` do cheatsheet é o primeiro a estourar.
    // -----------------------------------------------------------------
    readonly property int fontBase: 13

    readonly property int fsLabel:   fontBase - 2   // 11 — rótulos de campo, MAIÚSCULAS
    readonly property int fsCaption: fontBase - 1   // 12 — rodapés, dicas, contadores
    readonly property int fsBody:    fontBase       // 13 — texto corrente das listas
    readonly property int fsStrong:  fontBase + 1   // 14 — coluna principal, título de janela
    readonly property int fsLead:    fontBase + 2   // 15 — nome de item no omni, valor de campo
    readonly property int fsTitle:   fontBase + 3   // 16 — campo de busca, título de seção

    readonly property int fsHeading:  18            // cabeçalho de card, data por extenso
    readonly property int fsMetric:   19            // número de destaque nos cards do system
    readonly property int fsClock:    44            // relógio do dashboard
    readonly property int fsTemp:     52            // temperatura do weather

    // -----------------------------------------------------------------
    // Geometria acoplada à fonte
    //
    // Estes três acompanham `fontBase` porque são caixas que contêm
    // texto: se a fonte cresce e eles não, o texto encosta na borda.
    // -----------------------------------------------------------------
    readonly property int rowHeight:    fontBase * 3          // 39 — linha de lista
    readonly property int searchHeight: fontBase * 4 + 4      // 56 — campo de busca
    readonly property int buttonHeight: fontBase * 3 + 5      // 44 — botão de ícone

    // -----------------------------------------------------------------
    // Geometria da barra
    //
    // `islandHeight` NÃO deriva de `fontBase`: a barra é a única superfície
    // que reserva espaço na tela via exclusiveZone, e mudá-la desloca todas
    // as janelas. Merece ser uma decisão isolada.
    // -----------------------------------------------------------------
    readonly property int islandHeight: 34
    readonly property int islandRadius: 10
    readonly property int topMargin: 8
    readonly property int sideMargin: 14
    readonly property int pad: 12
    readonly property int gap: 10
}

