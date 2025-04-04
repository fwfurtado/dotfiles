use std

export-env {

    load-env {
        GIT_TERMINAL_PROMPT: 1
        GOPATH: ($env | get HOME | path join 'go')
        GOPRIVATE: "github.com/NSXBet/*"
        GOPROXY: "https://proxy.golang.org,direct"
    }

    std path add ($env | get GOPATH | path join 'bin')
}