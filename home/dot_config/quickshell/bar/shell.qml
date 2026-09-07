import Quickshell

// Ponto de entrada. Rode com:  qs -c ~/.config/quickshell
//
// Recarrega sozinho ao salvar qualquer arquivo desta pasta — deixe um
// `qs -c ~/.config/quickshell` num terminal enquanto edita e você vê o
// erro de QML na hora, em vez de descobrir que a barra sumiu.
ShellRoot {
    Variants {
        model: Quickshell.screens

        LeftIsland {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        CenterIsland {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        RightIsland {
            property var modelData
            screen: modelData
        }
    }

    Notifications {}
    Osd {}
}
