export GITHUB_PERSONAL_ACCESS_TOKEN={{command_output "op read 'op://development/GitHub Personal Access Token/token'"}}
export GPR_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN
export CONSUL_HTTP_ADDR={{command_output "op read 'op://homelab/Consul Server/address'"}}
export CONSUL_HTTP_TOKEN={{command_output "op read 'op://homelab/Consul Server/acl management/secret-id'"}}
