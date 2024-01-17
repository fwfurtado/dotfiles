use std

export-env {

    load-env {
        GOPATH: ($env | get HOME | path join 'go')
        GOPRIVATE: "github.com/github.com/nsxbet/*"
        GOPROXY: "https://proxy.golang.org,direct"
    }

    std path add ($env | get GOPATH | path join 'bin')
}