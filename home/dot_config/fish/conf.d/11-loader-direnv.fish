if status is-interactive
    cached-init direnv; or begin
        command -q direnv; and direnv hook fish | source
    end
end
