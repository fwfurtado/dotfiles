if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.local/bin

    starship init fish | source
    source ~/.asdf/asdf.fish
end
