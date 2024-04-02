export alias cat = bat
export alias md = mkdir
export alias fetch = http get

export def ll [path:string = '.'] { ls -l  $path | select name target user group type mode size inode modified  | table }
export def la [path:string = '.'] { ls -la $path | select name target user group type mode size inode modified  | table }

export def please [] { sudo !! }
export def pls [] { sudo !! }

export def bkp [$file: string] {
    cp $file $"($file).bkp"
}