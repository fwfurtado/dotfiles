use std

export-env {

    load-env {
        CABAL_HOME: ($env | get HOME | path join '.cabal')
        GHCUP_HOME: ($env | get HOME | path join '.ghcup')
    }

    std path add ($env | get CABAL_HOME | path join 'bin')
    std path add ($env | get GHCUP_HOME | path join 'bin')
}