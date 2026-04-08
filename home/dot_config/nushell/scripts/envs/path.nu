use std

export-env {
    std path add '/usr/local/bin' # only for ubuntu ¯\_(ツ)_/¯
    std path add ($env | get HOME | path join '.local/bin')
    std path add ($env | get HOME | path join 'bin') # I don't remember why I have this
}