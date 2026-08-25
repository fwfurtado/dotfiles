# Reaproveita um agente já existente; só sobe um novo se não houver socket vivo.
set -l agent_env $HOME/.ssh/agent-env.fish

if test -f $agent_env
    source $agent_env
end

if not test -S "$SSH_AUTH_SOCK"
    ssh-agent -c | sed 's/^setenv/set -gx/; s/;$//' >$agent_env
    chmod 600 $agent_env
    source $agent_env
end
