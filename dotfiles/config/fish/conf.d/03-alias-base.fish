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


function sudo_bang_bang
	echo "sudo $history[1]"
end

abbr --add pls --function sudo_bang_bang

alias cat='bat'

alias l ='eza --icons'
alias ls='eza --icons'
alias la='eza --icons -a'
alias ll='eza --icons -l --git --octal-permissions'
alias lla='eza --icons -a -l --git --octal-permissions'

export LS_TREE_IGNORE="cache|log|logs|node_modules|vendor"

alias lt='eza --icons --tree -D -L 2 -I "$LS_TREE_IGNORE"'
alias ltt='eza --icons --tree -D -L 3 -I "$LS_TREE_IGNOR"'
alias lttt='eza --icons --tree -D -L 4 -I "$LS_TREE_IGNORE"'
alias ltttt='eza --icons --tree -D -L 5 -I "$LS_TREE_IGNORE"'

alias k='kubectl'
