use std

export-env {
    load-env {
        DOTNET_ROOT: ($env | get HOME | path join '.dotnet')
    }

    std path add ($env | get DOTNET_ROOT | path join 'tools')
}