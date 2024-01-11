use std

export-env {

    load-env {
        GOPATH: ($env | get HOME | path join 'go')
        GOPRIVATE: "github.com/github.com/nsxbet/*"
    }

    std path add ($env | get GOPATH | path join 'bin')
}