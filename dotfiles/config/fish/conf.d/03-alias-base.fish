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
	
	cd $argv
end


function bang_bang
	echo $history[1]
end

abbr --add !! --position anywhere --function bang_bang

alias please='sudo' 
alias cat='bat'

