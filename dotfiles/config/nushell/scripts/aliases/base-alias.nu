export alias cat = bat
export alias md = mkdir


export def ll [path:string = '.'] { ls -l  $path | select name target user group type mode size inode modified  | table }
export def la [path:string = '.'] { ls -la $path | select name target user group type mode size inode modified  | table }
export def dowload [url:string] { curl -O $url }


export def please [] {
    let command = history | last | get command
     nu -c $'sudo (history | last | get command)'
}

export alias pls = please

export def bkp [$file: string] {
    cp $file $"($file).bkp"
}