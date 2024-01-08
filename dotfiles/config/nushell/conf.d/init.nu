# use aliases *
# use completions *
# use custom-commands *

# export-env {
#     use loaders *
# }

use loaders

overlay use carapace
overlay use mise
overlay use zoxide
overlay use starship

overlay use envs
overlay use custom-commands

use completions
overlay use btrfs-completions
overlay use make-completions
overlay use mask-completions
overlay use poetry-completions
overlay use systemctl-completions


use aliases
overlay use base-alias
overlay use copy_paste-alias
overlay use git-alias
overlay use kubectl-alias