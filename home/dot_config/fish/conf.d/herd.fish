set DEFAULT_PROJECTS_DIR "$HOME/projects/fwfurtado" "$HOME/projects/nsx" "$HOME/projects/poc"
set DEFAULT_AGENT "pi"

function herd --description "Cria ou foca um workspace herdr para um projeto"
    argparse --name=herd --max-args=1 \
        h/help \
        'k/kind=' \
        'n/name=' \
        'd/dir=' \
        'l/label=' \
        'w/watch=' \
        no-watch \
        no-agent \
        no-focus \
        -- $argv
    or return 2

    if set -q _flag_help
        printf '%s\n' \
            "uso: herd [PROJETO] [opções]" \
            "" \
            "  PROJETO           nome do diretório procurado em \$herd_roots." \
            "                    Omitido: usa a raiz do git atual, ou o pwd." \
            "" \
            "  -d, --dir PATH    caminho explícito, ignora \$herd_roots" \
            "  -k, --kind KIND   kind do agente (default: \$herd_kind, ou 'pi')" \
            "  -n, --name NOME   nome do agente (default: slug do diretório)" \
            "  -l, --label TXT   label do workspace (default: nome do diretório)" \
            "  -w, --watch CMD   comando do pane de dev (default: mise run <task>)" \
            "      --no-watch    não cria o pane de dev" \
            "      --no-agent    só monta o layout, não sobe agente" \
            "      --no-focus    não rouba o foco ao terminar" \
            "  -h, --help        esta ajuda" \
            "" \
            "variáveis de ajuste (config.fish):" \
            "  set -g herd_roots ~/Projects ~/work" \
            "  set -g herd_kind pi" \
            "  set -g herd_watch_task watch"
        return 0
    end

    # ---------- defaults: builtin < variável global < flag ----------
    set -l roots $DEFAULT_PROJECTS_DIR
    set -q herd_roots; and set roots $herd_roots

    set -l kind $DEFAULT_AGENT
    set -q herd_kind; and set kind $herd_kind
    set -q _flag_kind; and set kind $_flag_kind

    set -l task watch
    set -q herd_watch_task; and set task $herd_watch_task

    # ---------- pré-condições ----------
    for bin in herdr jq
        if not command -q $bin
            echo "herd: '$bin' não encontrado no PATH" >&2
            return 127
        end
    end

    if not herdr status server >/dev/null 2>&1
        echo "herd: servidor herdr não está rodando — abra 'herdr' ou suba 'herdr server'" >&2
        return 1
    end

    # ---------- resolver o diretório do projeto ----------
    set -l root
    if set -q _flag_dir
        set root $_flag_dir
    else if set -q argv[1]
        # aceita 'the-lab-zone' e também 'personal/the-lab-zone'
        set -l cands
        for base in $roots
            set -a cands $base/$argv[1]
            set -a cands (path dirname $base)/$argv[1]
        end
        for c in $cands
            if test -d $c
                set root $c
                break
            end
        end
        if not set -q root[1]
            echo "herd: projeto '$argv[1]' não encontrado em: $roots" >&2
            return 1
        end
    else
        set root (git rev-parse --show-toplevel 2>/dev/null; or pwd)
    end

    if not test -d $root
        echo "herd: '$root' não é um diretório" >&2
        return 1
    end
    set root (path resolve $root)

    # ---------- label e nome do agente ----------
    # agent start exige [a-z][a-z0-9_-]{0,31}
    set -l label (path basename $root)
    set -q _flag_label; and set label $_flag_label
    set -l name (__herd_slug $label)
    set -q _flag_name; and set name $_flag_name

    if test -z "$name"
        echo "herd: não consegui derivar um nome de agente de '$label' — use --name" >&2
        return 1
    end

    # ---------- idempotência: já existe workspace com esse label? ----------
    set -l existing (herdr workspace list 2>/dev/null \
        | jq -r --arg l "$label" \
            'first(.. | objects | select(.label? == $l) | .workspace_id? | strings) // empty')

    if test -n "$existing"
        set -q _flag_no_focus; or herdr workspace focus $existing >/dev/null
        echo "herd: '$label' já existe ($existing)"
        return 0
    end

    # ---------- workspace + agente ----------
    set -l ws (herdr workspace create --cwd $root --label $label --no-focus | string collect)
    if test $status -ne 0; or test -z "$ws"
        echo "herd: falha ao criar o workspace" >&2
        return 1
    end

    set -l wsid (echo $ws | jq -r '.result.workspace.workspace_id')
    set -l main (echo $ws | jq -r '.result.root_pane.pane_id')

    set -l started
    if not set -q _flag_no_agent
        if herdr agent start $name --kind $kind --pane $main >/dev/null
            set started $name
        else
            echo "herd: agente '$name' não subiu — nome duplicado ou kind inválido? layout mantido" >&2
        end
    end

    # ---------- pane de dev ----------
    set -l watch_cmd
    if set -q _flag_watch
        set watch_cmd $_flag_watch
    else if not set -q _flag_no_watch
        pushd $root
        if mise tasks --json 2>/dev/null \
            | jq -e --arg t $task '[.. | objects | .name? | strings] | index($t)' >/dev/null
            set watch_cmd "mise run $task"
        end
        popd
    end

    if test -n "$watch_cmd"
        set -l dev (herdr tab create --workspace $wsid --label dev --no-focus | string collect)
        set -l devpane (echo $dev | jq -r '.result.root_pane.pane_id')
        herdr pane run $devpane "$watch_cmd" >/dev/null
    end

    herdr tab create --workspace $wsid --label review --no-focus >/dev/null

    set -q _flag_no_focus; or herdr workspace focus $wsid >/dev/null

    set -l note
    test -n "$started"; and set -a note "agente: $started"
    test -n "$watch_cmd"; and set -a note "watch: $watch_cmd"

    if test (count $note) -gt 0
        echo "herd: $label → $wsid ("(string join ', ' $note)")"
    else
        echo "herd: $label → $wsid"
    end
end

function __herd_qualify -a path --description "bucket/projeto a partir do caminho absoluto"
    echo (path basename (path dirname $path))/(path basename $path)
end

function herdp --description "Escolhe um projeto com fzf e foca ou cria o workspace herdr"
    argparse --name=herdp --ignore-unknown h/help -- $argv
    or return 2

    if set -q _flag_help
        printf '%s\n' \
            "uso: herdp [opções repassadas ao herd]" \
            "" \
            "  Lista workspaces já abertos (●) e projetos ainda não abertos (○)." \
            "  enter  foca o que já existe, chama 'herd' no que não existe" \
            "  tab    marca vários (bom para cold start)" \
            "  ctrl-o abre o diretório no Zed sem sair do picker" \
            "" \
            "  Qualquer outra flag é repassada ao herd:" \
            "    herdp -k claude --no-watch"
        return 0
    end

    for bin in herdr jq fzf
        if not command -q $bin
            echo "herdp: '$bin' não encontrado no PATH" >&2
            return 127
        end
    end

    if not herdr status server >/dev/null 2>&1
        echo "herdp: servidor herdr não está rodando — abra 'herdr' ou suba 'herdr server'" >&2
        return 1
    end

    set -l roots $DEFAULT_PROJECTS_DIR
    set -q herd_roots; and set roots $herd_roots

    # ---------- workspaces abertos ----------
    set -l open_labels
    set -l rows

    for line in (herdr workspace list 2>/dev/null \
        | jq -r '[.. | objects | select(has("workspace_id") and has("label"))]
                 | unique_by(.workspace_id)[]
                 | "\(.label)\t\(.workspace_id)"')

        set -l parts (string split \t $line)
        test (count $parts) -eq 2; or continue

        set -l label $parts[1]
        set -l path ""
        for base in $roots
            if test -d $base/$label
                set path (path resolve $base/$label)
                break
            end
        end

        set -l shown $label
        test -n "$path"; and set shown (__herd_qualify $path)

        set -a open_labels $label
        set -a rows (string join \t "● $shown" $parts[2] $path)
    end

    # ---------- projetos ainda não abertos ----------
    set -l seen $open_labels
    for base in $roots
        test -d $base; or continue
        for d in $base/*/
            set -l name (path basename $d)
            contains -- $name $seen; and continue
            set -l path (path resolve $d)
            set -a seen $name
            set -a rows (string join \t "○ "(__herd_qualify $path) "" $path)
        end
    end

    if test (count $rows) -eq 0
        echo "herdp: nada encontrado em: $roots" >&2
        return 1
    end

    # ---------- picker ----------
    set -l picked (printf '%s\n' $rows | fzf \
        --multi \
        --delimiter \t \
        --with-nth 1 \
        --prompt 'herd> ' \
        --header 'enter: focar/criar   tab: marcar vários   ctrl-o: abrir no Zed' \
        --bind 'ctrl-o:execute-silent(zed {3} 2>/dev/null)' \
        --preview 'git -C {3} log --oneline -8 2>/dev/null || ls -1 {3} 2>/dev/null' \
        --preview-window 'right,55%,border-left')

    # esc / ctrl-c: sai em silêncio
    or return 0

    # ---------- agir ----------
    set -l n (count $picked)
    for i in (seq $n)
        set -l parts (string split \t $picked[$i])
        set -l id $parts[2]
        set -l label (string replace -r '^[●○] ' '' $parts[1])

        # só o último item rouba o foco
        set -l extra
        test $i -lt $n; and set extra --no-focus

        if test -n "$id"
            if test -z "$extra"
                herdr workspace focus $id >/dev/null
            end
            echo "herdp: $label ($id)"
        else
            herd --dir $parts[3] $extra $argv
        end
    end
end


function __herd_slug -a raw --description "Normaliza para o formato de nome de agente do herdr: [a-z][a-z0-9_-]{0,31}"
    string lower -- $raw \
        | string replace -ra '[^a-z0-9_-]' '-' \
        | string replace -ra -- '-+' '-' \
        | string replace -r '^[^a-z]+' '' \
        | string replace -r -- '-$' '' \
        | string sub -l 32
end


function herd-wt --description "Cria um worktree git como workspace herdr e sobe um agente nele"
    argparse --name=herd-wt --max-args=1 \
        h/help \
        'b/base=' \
        'p/path=' \
        'l/label=' \
        'k/kind=' \
        'n/name=' \
        'w/watch=' \
        'W/workspace=' \
        'C/cwd=' \
        'P/prompt=' \
        no-watch \
        no-agent \
        no-focus \
        -- $argv
    or return 2

    if set -q _flag_help
        printf '%s\n' \
            "uso: herd-wt BRANCH [opções]" \
            "" \
            "  Cria o checkout git, abre como workspace agrupado ao repo pai" \
            "  e sobe um agente no pane raiz." \
            "" \
            "  BRANCH               branch existente é usada; senão é criada" \
            "" \
            "  -b, --base REF       base da branch nova (default: HEAD)" \
            "  -p, --path PATH      caminho do checkout (default: config do herdr)" \
            "  -l, --label TXT      label do workspace (default: a própria branch)" \
            "  -k, --kind KIND      kind do agente (default: \$herd_kind, ou 'pi')" \
            "  -n, --name NOME      nome do agente (default: slug da branch)" \
            "  -P, --prompt TEXT    já manda esse prompt para o agente" \
            "  -w, --watch CMD      comando do pane de dev (default: mise run <task>)" \
            "  -W, --workspace ID   repo de origem (default: workspace focado)" \
            "  -C, --cwd PATH       repo de origem por caminho" \
            "      --no-watch       não cria o pane de dev" \
            "      --no-agent       só monta o layout" \
            "      --no-focus       não rouba o foco" \
            "" \
            "  Para listar e remover:  herdr worktree list / herdr worktree remove"
        return 0
    end

    if not set -q argv[1]
        echo "herd-wt: informe a branch (herd-wt --help)" >&2
        return 2
    end
    set -l branch $argv[1]

    if set -q _flag_workspace; and set -q _flag_cwd
        echo "herd-wt: use --workspace ou --cwd, não os dois" >&2
        return 2
    end

    # ---------- defaults ----------
    set -l kind $DEFAULT_AGENT
    set -q herd_kind; and set kind $herd_kind
    set -q _flag_kind; and set kind $_flag_kind

    set -l task watch
    set -q herd_watch_task; and set task $herd_watch_task

    set -l label $branch
    set -q _flag_label; and set label $_flag_label

    set -l name (__herd_slug $branch)
    set -q _flag_name; and set name $_flag_name

    # ---------- pré-condições ----------
    for bin in herdr jq
        if not command -q $bin
            echo "herd-wt: '$bin' não encontrado no PATH" >&2
            return 127
        end
    end

    if not herdr status server >/dev/null 2>&1
        echo "herd-wt: servidor herdr não está rodando" >&2
        return 1
    end

    if test -z "$name"; and not set -q _flag_no_agent
        echo "herd-wt: não consegui derivar um nome de agente de '$branch' — use --name" >&2
        return 1
    end

    # ---------- criar o worktree ----------
    set -l args --branch $branch --label $label --no-focus
    set -q _flag_base; and set -a args --base $_flag_base
    set -q _flag_path; and set -a args --path $_flag_path
    set -q _flag_workspace; and set -a args --workspace $_flag_workspace
    set -q _flag_cwd; and set -a args --cwd $_flag_cwd

    set -l wt (herdr worktree create $args | string collect)
    if test $status -ne 0; or test -z "$wt"
        echo "herd-wt: falha ao criar o worktree de '$branch'" >&2
        return 1
    end

    set -l wsid (echo $wt | jq -r '.result.workspace.workspace_id')
    set -l main (echo $wt | jq -r '.result.root_pane.pane_id')

    if test -z "$wsid"; or test "$wsid" = null
        echo "herd-wt: resposta inesperada do worktree create" >&2
        echo $wt >&2
        return 1
    end

    # ---------- agente ----------
    set -l started
    if not set -q _flag_no_agent
        if herdr agent start $name --kind $kind --pane $main >/dev/null
            set started $name
            if set -q _flag_prompt
                herdr agent prompt $name $_flag_prompt >/dev/null
                or echo "herd-wt: agente subiu mas o prompt não foi aceito" >&2
            end
        else
            echo "herd-wt: agente '$name' não subiu — nome duplicado ou kind inválido? layout mantido" >&2
        end
    end

    # ---------- pane de dev ----------
    set -l watch_cmd
    if set -q _flag_watch
        set watch_cmd $_flag_watch
    else if not set -q _flag_no_watch
        # o cwd do pane raiz é o checkout novo
        set -l wtroot (herdr pane get $main 2>/dev/null \
            | jq -r 'first(.. | objects | select(has("pane_id")) | .cwd? | strings) // empty')

        if test -n "$wtroot"; and test -d $wtroot
            pushd $wtroot
            if mise tasks --json 2>/dev/null \
                | jq -e --arg t $task '[.. | objects | .name? | strings] | index($t)' >/dev/null
                set watch_cmd "mise run $task"
            end
            popd
        end
    end

    if test -n "$watch_cmd"
        set -l dev (herdr tab create --workspace $wsid --label dev --no-focus | string collect)
        set -l devpane (echo $dev | jq -r '.result.root_pane.pane_id')
        herdr pane run $devpane "$watch_cmd" >/dev/null
    end

    set -q _flag_no_focus; or herdr workspace focus $wsid >/dev/null

    set -l note
    test -n "$started"; and set -a note "agente: $started"
    test -n "$watch_cmd"; and set -a note "watch: $watch_cmd"
    set -q _flag_prompt; and test -n "$started"; and set -a note "prompt enviado"

    if test (count $note) -gt 0
        echo "herd-wt: $branch → $wsid ("(string join ', ' $note)")"
    else
        echo "herd-wt: $branch → $wsid"
    end
end
