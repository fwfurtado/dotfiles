alias cat = bat
alias src = source ~/.config/nushell/config.nu 
alias ll = (ls -l  | select name target uid group type mode size inode modified | table)
alias la = (ls -la | select name target uid group type mode size inode modified | table)
alias pbcopy  = xsel --clipboard --input
alias pbpaste = xsel --clipboard --output
alias md = mkdir 


# git
alias ga = git add

alias gcl = git clone

alias gcmsg = git commit -m
alias gcam = git commit --amend -C HEAD
alias gca = git commit --amend = 

alias gpl = git pull
alias gplr = git pull --rebase
alias gps = git push
alias gpsf = git push -f
alias gpsup = git push --set-upstream (git remote | into string | str trim) (git rev-parse --abbrev-ref HEAD | into string | str trim)
alias grv = git remote -v

alias grb = git rebase
alias grbo = git rebase --onto
alias grba = git rebase --abort
alias grbc = git rebase --continue
alias grbi = git rebase -i

alias gsq  = git reset (git merge-base main (git rev-parse --abbrev-ref HEAD))

alias grs  = git reset --
alias grsf = git reset --hard

alias gr   = git restore
alias grt = git restore --staged

alias gs = git status

alias gsh = git stash
alias gshu = git stash --include-untracked
alias gshl = git stash list
alias gshp = git stash pop

alias gsw = git switch
alias gsc = git switch -c

alias gb  = git branch

alias gt = git tag

# git dotfiles
alias .g     = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME
alias .ga    = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME add
alias .gash  = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME stash
alias .gashl = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME stash list
alias .gashp = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME stash pop
alias .gashu = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME stash --include-untracked
alias .gcmsg = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME commit -m
alias .gdf   = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME diff --
alias .gpl   = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME pull
alias .gplr  = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME pull --rebase
alias .gps   = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME push
alias .grb   = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME rebase
alias .grs   = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME reset --
alias .gs    = git --git-dir $env.DOTFILES_REPO --work-tree $env.HOME status


#Docker
alias dk   = docker
alias dkc  = docker container
alias dkcr = docker container run
alias dkcs = docker container stop
alias dkcet = docker container exec -it
alias dkcls = docker container ls

alias dkv  = docker volume
alias dkvc = docker volume create
alias dkvr = docker volume remove
alias dkvls = docker volume ls

# Docker Compose
alias dc = docker-compose
alias dcu = docker-compose up
alias dcd = docker-compose down
alias dcls = docker-compose ps
alias dcex = docker-compose exec
