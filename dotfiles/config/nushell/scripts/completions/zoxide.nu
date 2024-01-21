def "nu-complete zoxide path" [] {
    let previous = {score: 100 path: '-'}

    zoxide query -ls  --exclude $env.PWD
    | lines 
    | str trim 
    | parse '{score} {path}' 
    | append $previous
    | update score {|row| $row.score | into float }
    | sort-by -r score 
    | get path
}

export def "z_completed" [
    path: string@"nu-complete zoxide path"
] {
    echo $path
}