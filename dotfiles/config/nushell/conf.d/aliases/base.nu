export alias cat = bat
export alias md = mkdir 

export def ll [] { ls -l  | select name target user group type mode size inode modified  | table }
export def la [] { ls -la  | select name target user group type mode size inode modified  | table }

export def please [] { sudo !! }
export def pls [] { sudo !! }