abbr --add g git
abbr --add ga git add

abbr --add gint git init

abbr --add grs  git reset
abbr --add grss git reset --soft
abbr --add grsf git reset --hard

abbr --add gr git restore
abbr --add gr- git restore --staged

abbr --add gs git status

abbr --add gst git stash
abbr --add gstf git stash --include-untracked
abbr --add gstp git stash pop
abbr --add gstl git stash list

abbr --add gsw git switch
abbr --add gsc git switch -c

abbr --add gb git branch
abbr --add gt git tag

abbr --add gpl git pull
abbr --add gplr git pull --rebase

abbr --add gps git push
abbr --add gpsf git push -f
abbr --add gpsup 'git push --set-upstream (git remote) (git rev-parse --abbrev-ref HEAD)'

abbr --add grb git rebase
abbr --add grpo git rebase --onto
abbr --add grba git rebase --abort
abbr --add grbc git rebase --continue

abbr --add gcmsg git commit -m
abbr --add gamend git commit --amend -C HEAD

abbr --add gcl gh repo clone
abbr --add gsq 'git reset (git merge-base main (git rev-parse --abbrev-ref HEAD))'


abbr --add gwl git worktree list
abbr --add gwa git worktree add
abbr --add gwr git worktree remove
abbr --add gwrf git worktree remove --force


function gclone
	set -l name (path change-extension '' $argv | path basename)
	echo -e '\n'

	git clone $argv

	cd $name
end

abbr -a clone_git_repositories --position command --regex '.+\.git' --function gclone
