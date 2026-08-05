function __herd_projects
    set -l roots ~/projects/personal ~/projects/work ~/projects/poc
    set -q herd_roots; and set roots $herd_roots
    for base in $roots
        test -d $base; or continue
        set -l bucket (path basename $base)
        for d in $base/*/
            printf '%s\t%s\n' $bucket/(path basename $d) $bucket
        end
    end
end

complete -c herd -f
complete -c herd -n __fish_is_first_arg -a '(__herd_projects)'

complete -c herd -s h -l help -d 'Mostra a ajuda'
complete -c herd -s d -l dir -r -F -d 'Caminho explícito do projeto'
complete -c herd -s l -l label -r -d 'Label do workspace'
complete -c herd -s n -l name -r -d 'Nome do agente'
complete -c herd -s w -l watch -r -d 'Comando do pane de dev'
complete -c herd -s k -l kind -r -d 'Kind do agente' -a '
pi\tPi
claude\t"Claude Code"
codex\tCodex
gemini\tGemini
cursor\t"Cursor Agent"
devin\t"Devin CLI"
agy\t"Antigravity CLI"
cline\tCline
omp\tOMP
mastracode\tMastraCode
opencode\tOpenCode
copilot\t"GitHub Copilot CLI"
kimi\t"Kimi Code CLI"
kiro\tKiro
droid\tDroid
amp\tAmp
grok\t"Grok CLI"
hermes\t"Hermes Agent"
kilo\t"Kilo Code CLI"
qodercli\t"Qoder CLI"
maki\tMaki'

complete -c herd -l no-watch -d 'Não cria o pane de dev'
complete -c herd -l no-agent -d 'Só monta o layout'
complete -c herd -l no-focus -d 'Não rouba o foco'


complete -c herdp -f
complete -c herdp -s h -l help -d 'Mostra a ajuda'
complete -c herdp -w herd


function __herd_wt_branches
    git for-each-ref --format='%(refname:short)\t%(committerdate:relative)' refs/heads 2>/dev/null
end

complete -c herd-wt -f
complete -c herd-wt -n __fish_is_first_arg -a '(__herd_wt_branches)'

complete -c herd-wt -s h -l help -d 'Mostra a ajuda'
complete -c herd-wt -s b -l base -r -a '(__herd_wt_branches)' -d 'Base da branch nova'
complete -c herd-wt -s p -l path -r -F -d 'Caminho do checkout'
complete -c herd-wt -s l -l label -r -d 'Label do workspace'
complete -c herd-wt -s n -l name -r -d 'Nome do agente'
complete -c herd-wt -s P -l prompt -r -d 'Prompt inicial para o agente'
complete -c herd-wt -s w -l watch -r -d 'Comando do pane de dev'
complete -c herd-wt -s W -l workspace -r -d 'Workspace do repo de origem'
complete -c herd-wt -s C -l cwd -r -F -d 'Repo de origem por caminho'
complete -c herd-wt -l no-watch -d 'Não cria o pane de dev'
complete -c herd-wt -l no-agent -d 'Só monta o layout'
complete -c herd-wt -l no-focus -d 'Não rouba o foco'

complete -c herd-wt -s k -l kind -r -d 'Kind do agente' -a '
pi\tPi
claude\t"Claude Code"
codex\tCodex
gemini\tGemini
cursor\t"Cursor Agent"
devin\t"Devin CLI"
agy\t"Antigravity CLI"
cline\tCline
omp\tOMP
mastracode\tMastraCode
opencode\tOpenCode
copilot\t"GitHub Copilot CLI"
kimi\t"Kimi Code CLI"
kiro\tKiro
droid\tDroid
amp\tAmp
grok\t"Grok CLI"
hermes\t"Hermes Agent"
kilo\t"Kilo Code CLI"
qodercli\t"Qoder CLI"
maki\tMaki'
