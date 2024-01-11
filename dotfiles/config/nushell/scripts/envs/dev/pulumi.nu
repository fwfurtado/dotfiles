use std

export-env {

    load-env {
        PULUMI_HOME: ($env | get HOME | path join '.pulumi')
    }

    std path add ($env | get PULUMI_HOME | path join 'bin')
}