eval (starship init elvish)

set edit:insert:binding[Ctrl-L] = $edit:clear~
set edit:insert:binding[Alt-l] = $edit:location:start~
set edit:insert:binding[Ctrl-t] = $edit:transpose-rune~
set edit:insert:binding[Alt-t] = $edit:transpose-word~
set edit:insert:binding[Alt-Backspace] = $edit:kill-small-word-left~


use asdf _asdf; var asdf~ = $_asdf:asdf~

set edit:completion:arg-completer[asdf] = $_asdf:arg-completer~

set E:FZF_DEFAULT_OPTS = '--height 40% --no-bold --layout reverse --border'
set E:GPG_TTY = ( tty )
set E:EDITOR = 'lvim'
set E:VISUAL = 'lvim'
set E:ERL_AFLAGS = '-kernel shell_history enabled'
set E:SUDO_EDITOR = 'lvim'
set E:CHROME_EXECUTABLE = '/usr/bin/google-chrome-stable'
set E:BROWSER = 'google-chrome-stable'
set E:ANDROID_SDK = $E:HOME'/Android/Sdk' 
set E:GOPATH = $E:HOME'/go' 
set E:GOPRIVATE = "go.buf.build"
set E:PERSONAL_ACCESS_TOKEN = "<TOKEN>"

use path

if ( path:is-regular (asdf which java) ) {
    set E:JAVA_HOME = ( path:dir ( path:dir (asdf which java) ) )
    set E:JDK_HOME = $E:JAVA_HOME
}


set paths = [
    $@paths
    /var/lib/snapd/bin
    $E:ANDROID_SDK/platform-tools
    $E:ANDROID_SDK/tools/bin
    $E:ANDROID_SDK/tools
    $E:GOPATH/bin
    $E:HOME/.ghcup/bin
    $E:HOME/.cabal/bin
    $E:HOME/.cargo/bin
]

use epm
epm:install &silent-if-installed=$true github.com/zzamboni/elvish-modules

use github.com/zzamboni/elvish-modules/bang-bang
use github.com/zzamboni/elvish-modules/alias

alias:new pbcopy  xsel --clipboard --input
alias:new pbpaste xsel --clipboard --output
alias:new md mkdir 
alias:new ls exa --group-directories-first --icons $@args 
alias:new ll exa --group-directories-first --icons -l
alias:new la exa --group-directories-first --icons -a 
alias:new lt exa --icons --tree


# git
alias:new ginit  git init
alias:new ga  git add

alias:new gcl  git clone

alias:new gcmsg  git commit -m
alias:new gcam  git commit --amend -C HEAD
alias:new gca  git commit --amend = 

alias:new gpl  git pull
alias:new gplr  git pull --rebase
alias:new gps  git push
alias:new gpsf  git push -f
fn gpsup  { git push --set-upstream (git remote) (git rev-parse --abbrev-ref HEAD) }
alias:new grv  git remote -v

alias:new grb  git rebase
alias:new grbo  git rebase --onto
alias:new grba  git rebase --abort
alias:new grbc  git rebase --continue
alias:new grbi  git rebase -i

fn gsq  { git reset (git merge-base main (git rev-parse --abbrev-ref HEAD)) }

alias:new grs   git reset --
alias:new grsf  git reset --hard

alias:new gr    git restore
alias:new grt  git restore --staged

alias:new gs  git status

alias:new gsh  git stash
alias:new gshu  git stash --include-untracked
alias:new gshl  git stash list
alias:new gshp  git stash pop

alias:new gsw  git switch
alias:new gsc  git switch -c

alias:new gb   git branch

alias:new gt  git tag

#Docker
alias:new dk    docker
alias:new dkc   docker container
alias:new dkcr  docker container run
alias:new dkcs  docker container stop
alias:new dkcet  docker container exec -it
alias:new dkcls  docker container ls

alias:new dkv   docker volume
alias:new dkvc  docker volume create
alias:new dkvr  docker volume remove
alias:new dkvls  docker volume ls

# Docker Compose
alias:new dc  docker-compose
alias:new dcu  docker-compose up
alias:new dcd  docker-compose down
alias:new dcls  docker-compose ps
alias:new dcex  docker-compose exec


alias:save &all

use str

fn gbrm { |name|
    var OLD_NAME = (str:trim-space (git rev-parse --abbrev-ref HEAD))
    var NEW_NAME = $name
    var REMOTE = (str:trim-space (git remote))



    # Rename local branch
    git branch -M $OLD_NAME $NEW_NAME
    
    # Delete old branch on remote
    git push $REMOTE :$OLD_NAME

    # Remove upstream of new branch (this avoid that git uses the old name when push)
    git branch --unset-upstream $NEW_NAME

    # Push new branch to remote 
    git push $REMOTE $NEW_NAME 

    # Set upstream to new branch
    git push $REMOTE -u $NEW_NAME
}
