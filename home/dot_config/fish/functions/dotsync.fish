# dotsync.fish
function dotsync --description 'traz alterações do $HOME (autoCommit cuida do git)'
    chezmoi re-add $argv; or return $status

    # autoCommit já commitou; mostra o que entrou
    chezmoi git -- log --oneline -3
end

