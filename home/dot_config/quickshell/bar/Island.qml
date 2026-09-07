import QtQuick
import QtQuick.Layouts

// Container comum das três ilhas. Existe para que borda, raio e padding
// sejam definidos num lugar só — mudar o vocabulário visual é editar
// este arquivo, não três.
Rectangle {
    id: root

    default property alias content: layout.data
    property int spacing: Theme.gap

    // Piso de largura. A ilha continua crescendo com o conteúdo; isto só
    // impede que ela encolha demais quando o conteúdo é curto — o caso da
    // ilha central sem mídia tocando, que ficaria uma pastilha minúscula
    // perdida no meio de 5120px.
    property int minWidth: 0

    implicitWidth: Math.max(minWidth, layout.implicitWidth + Theme.pad * 2)
    implicitHeight: Theme.islandHeight

    color: Theme.surface
    radius: Theme.islandRadius
    border.width: 1
    border.color: Theme.border

    // Centralizado, não `anchors.fill`. Com fill, o RowLayout ocupa toda a
    // ilha e empacota o conteúdo à esquerda — quando `minWidth` deixa a
    // ilha mais larga que o conteúdo, sobra um vazio à direita e o
    // conteúdo fica descolado. Centralizando, o padding vira simetria
    // automática e as ilhas cujo tamanho vem do conteúdo não mudam nada.
    RowLayout {
        id: layout
        anchors.centerIn: parent
        height: parent.height
        spacing: root.spacing
    }
}
