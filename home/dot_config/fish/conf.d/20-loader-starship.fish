if status is-interactive
    cached-init starship; or begin
        command -q starship; and starship init fish | source
    end
end
