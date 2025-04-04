use std

export-env {

    load-env {
        RUSTUP_HOME: ($env | get HOME | path join '.rustup')
        CARGO_HOME: ($env | get HOME | path join '.cargo')
    }

    std path add ($env | get CARGO_HOME | path join 'bin')
}