use std

export-env {
    load-env {
        KREW_HOME: ($env | get HOME | path join '.krew')
    }

    std path add ($env | get KREW_HOME | path join 'bin')
}