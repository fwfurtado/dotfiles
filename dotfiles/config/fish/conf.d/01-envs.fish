export SYSTEMD_EDITOR=nvim
export EDITOR=nvim
export ANDROID_SDK=$HOME/Android/Sdk
export DOTNET_ROOT=$HOME/.dotnet
export SYSTEMD_EDITOR=nvim
export EDITOR=nvim

fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/.pulumi/bin
fish_add_path $DOTNET_ROOT
fish_add_path $DOTNET_ROOT/tools
fish_add_path $HOME/.krew/bin
fish_add_path $ANDROID_SDK/platform-tools
fish_add_path $ANDROID_SDK/tools/bin
fish_add_path $ANDROID_SDK/tools


export TASK_X_REMOTE_TASKFILES=1
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
