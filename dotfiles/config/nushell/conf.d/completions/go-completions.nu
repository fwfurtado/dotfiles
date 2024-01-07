# force rebuild
export extern "go" [

	...args
]

# compile packages and dependencies
export extern "go build" [

	...args
]

# remove object files
export extern "go clean" [

	...args
]

# run godoc on package sources
export extern "go doc" [

	...args
]

# print Go environment information
export extern "go env" [

	...args
]

# run go tool fix on packages
export extern "go fix" [

	...args
]

# run gofmt on package sources
export extern "go fmt" [

	...args
]

# download and install packages and dependencies
export extern "go get" [

	...args
]

# Generate runs commands described by directives within existing files.
export extern "go generate" [

	...args
]

# get help on topic
export extern "go help" [

	...args
]

# compile and install packages and dependencies
export extern "go install" [

	...args
]

# list packages
export extern "go list" [

	...args
]

# compile and run Go program
export extern "go run" [

	...args
]

# test packages
export extern "go test" [

	...args
]

# run specified go tool
export extern "go tool" [

	...args
]

# target tool
export extern "go addr2line api asm cgo compile dist fix link nm objdump pack pprof prof vet yacc" [

	...args
]

# print Go version
export extern "go version" [

	...args
]

# vet packages
export extern "go vet" [

	...args
]

# module maintenance
export extern "go mod" [

	...args
]

# download modules to local cache
export extern "go download" [

	...args
]

# edit go.mod from tools or scripts
export extern "go edit" [

	...args
]

# print module requirement graph
export extern "go graph" [

	...args
]

# initialize new module in current directory
export extern "go init" [

	...args
]

# add missing and remove unused modules
export extern "go tidy" [

	...args
]

# make vendored copy of dependencies
export extern "go vendor" [

	...args
]

# verify dependencies have expected content
export extern "go verify" [

	...args
]

# explain why packages or modules are needed
export extern "go why" [

	...args
]