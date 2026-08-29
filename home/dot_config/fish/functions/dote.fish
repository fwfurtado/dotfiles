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

