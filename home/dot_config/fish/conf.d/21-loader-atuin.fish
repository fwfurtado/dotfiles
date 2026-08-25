# Login fica na função `atuin-login` — não pode tocar o 1Password no startup.
if status is-interactive; and command -q atuin
    atuin init fish --disable-up-arrow | source
end
