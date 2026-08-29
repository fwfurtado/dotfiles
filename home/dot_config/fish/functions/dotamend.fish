# dotamend.fish
function dotamend --description 'reescreve a mensagem do último commit'
    chezmoi git -- commit --amend
end
