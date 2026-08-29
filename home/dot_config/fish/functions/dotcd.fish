# dotcd.fish
function dotcd --description 'vai para a raiz do repo de dotfiles'
    cd (chezmoi source-path)/..
end

