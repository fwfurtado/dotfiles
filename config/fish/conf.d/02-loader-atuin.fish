if test -f ~/.atuin/bin/env.fish
    source ~/.atuin/bin/env.fish
    atuin init fish --disable-up-arrow | source

    if atuin status | grep -qi "you are not logged in"
        atuin login -u "$(op read 'op://development/Atuin/username')" -p "$(op read 'op://development/Atuin/pass')" -k "$(op read 'op://development/Atuin/key')"
    end
end
