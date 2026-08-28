# Variáveis de ambiente. Sem PATH aqui (ver 01-path.fish.tmpl).
set -gx EDITOR nvim
set -gx SYSTEMD_EDITOR nvim

set -gx ANDROID_SDK $HOME/Android/Sdk
set -gx DOTNET_ROOT $HOME/.dotnet
set -gx GOPATH $HOME/go

set -gx DOCKER_BUILDKIT 1
set -gx COMPOSE_DOCKER_CLI_BUILD 1
set -gx OMP_PROFILE mimi
set -gx LS_TREE_IGNORE "cache|log|logs|node_modules|vendor"
