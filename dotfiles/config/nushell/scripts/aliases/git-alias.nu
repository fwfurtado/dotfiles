
export def gitignore [...args] {
    let ignores = $args | str join ","
    let baseUrl = "https://www.toptal.com/developers/gitignore/api/"
    let url = $baseUrl | path join $ignores

    http get $url | save -f .gitignore
}

export alias ga = git add

export alias gcl = git clone

export alias gcmsg = git commit -m
export alias gcam = git commit --amend -C HEAD
export alias gca = git commit --amend

export alias gpl = git pull
export alias gplr = git pull --rebase
export alias gps = git push
export alias gpsf = git push -f
export alias gpsup = git push --set-upstream (git remote | into string | str trim) (git rev-parse --abbrev-ref HEAD | into string | str trim)
export alias grv = git remote -v

export alias grb = git rebase
export alias grbo = git rebase --onto
export alias grba = git rebase --abort
export alias grbc = git rebase --continue
export alias grbi = git rebase -i

export alias gsq  = git reset (git merge-base main (git rev-parse --abbrev-ref HEAD))

export alias grs  = git reset --
export alias grsf = git reset --hard

export alias gr   = git restore
export alias grt = git restore --staged

export alias gs = git status

export alias gst = git stash
export alias gstf = git stash --include-untracked
export alias gstl = git stash list
export alias gstp = git stash pop

export alias gsw = git switch
export alias gsc = git switch -c

export alias gb  = git branch

export alias gt = git tag