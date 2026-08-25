# Login fica na função `atuin-login` — não pode tocar o 1Password no startup.
if status is-interactive
    cached-init atuin; or begin
        command -q atuin; and atuin init fish --disable-up-arrow | source
    end
end
