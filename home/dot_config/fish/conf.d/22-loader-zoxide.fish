if status is-interactive
    cached-init zoxide; or begin
        command -q zoxide; and zoxide init --cmd cd fish | source
    end
end
