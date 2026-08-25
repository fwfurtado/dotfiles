# dot.fish
function dot --wraps chezmoi --description 'chezmoi'
    chezmoi $argv
end

# dotcd.fish
function dotcd --description 'vai para a raiz do repo de dotfiles'
    cd (chezmoi source-path)/..
end

# dote.fish
# home/dot_config/fish/functions/dote.fish
function dote --wraps 'chezmoi edit' --description 'edita a fonte; pergunta antes de adicionar arquivo não gerenciado'
    if not set -q argv[1]
        echo "dote: informe ao menos um arquivo" >&2
        return 1
    end

    for file in $argv
        # source-path sai != 0 quando o alvo não é gerenciado
        if chezmoi source-path $file &>/dev/null
            continue
        end

        if not test -e $file
            echo "dote: $file não existe" >&2
            return 1
        end

        read -l -P "dote: $file não é gerenciado. Adicionar? [y/N] " answer
        or return 1

        if not string match -qir '^y(es)?$' -- $answer
            echo "dote: cancelado" >&2
            return 1
        end

        chezmoi add $file
        or return $status
    end

    chezmoi edit --apply $argv
end

# dots.fish
function dots --description 'status + diff'
    chezmoi status
    chezmoi diff
end

# dotsync.fish
# dotsync.fish
function dotsync --description 'traz alterações do $HOME (autoCommit cuida do git)'
    chezmoi re-add $argv; or return $status

    # autoCommit já commitou; mostra o que entrou
    chezmoi git -- log --oneline -3
end

# dotup.fish
function dotup --description 'git pull + apply'
    chezmoi update $argv
end

# dotpush.fish
function dotpush --description 'sobe os commits pendentes'
    chezmoi git -- log --oneline origin/main..HEAD
    chezmoi git -- push
end


# dotamend.fish
function dotamend --description 'reescreve a mensagem do último commit'
    chezmoi git -- commit --amend
end
