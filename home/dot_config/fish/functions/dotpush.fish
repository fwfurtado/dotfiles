# dotpush.fish
function dotpush --description 'sobe os commits pendentes'
    chezmoi git -- log --oneline origin/main..HEAD
    chezmoi git -- push
end

