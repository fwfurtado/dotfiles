set fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.local/bin    
end

# Wasmer
export WASMER_DIR="/var/home/anyone/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"
