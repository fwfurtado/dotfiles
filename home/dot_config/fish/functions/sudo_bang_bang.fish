function sudo_bang_bang --description 'expande pls para sudo + último comando'
    echo "sudo $history[1]"
end
