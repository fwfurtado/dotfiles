# source ~/.config/op/plugins.sh

# Busca resiliente pelo socket do 1Password SSH Agent
set -l op_sockets \
    "$HOME/.1password/agent.sock" \
    "$HOME/snap/1password/current/.1password/agent.sock"

# for socket in $op_sockets
#     if test -S "$socket"
#         set -gx SSH_AUTH_SOCK "$socket"
#         break
#     end
# end
