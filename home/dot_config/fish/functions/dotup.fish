# dotup.fish
function dotup --description 'git pull + apply'
    chezmoi update $argv
end

