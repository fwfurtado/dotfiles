# dots.fish
function dots --description 'status + diff'
    chezmoi status
    chezmoi diff
end
