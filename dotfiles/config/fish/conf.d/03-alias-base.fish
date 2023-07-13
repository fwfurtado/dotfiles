alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

function md

	argparse 'k/keep' -- $argv
	or return

	mkdir -p $argv

	if set -ql _flag_k
		return $status
	end

	if test $status -ne 0
		return $stauts
	end

	z $argv
end


function bang_bang
	echo $history[1]
end

abbr --add !! --position anywhere --function bang_bang

alias please='sudo'
alias cat='bat'
alias ls='exa --icons'
alias la='exa --icons -a'
alias ll='exa --icons -l --git'

export LS_TREE_IGNORE="cache|log|logs|node_modules|vendor"

alias lt='exa --icons --tree -D -L 2 -I "$LS_TREE_IGNORE"'
alias ltt='exa --icons --tree -D -L 3 -I "$LS_TREE_IGNOR"'
alias lttt='exa --icons --tree -D -L 4 -I "$LS_TREE_IGNORE"'
alias ltttt='exa --icons --tree -D -L 5 -I "$LS_TREE_IGNORE"'

alias k='kubectl'
