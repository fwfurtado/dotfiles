# force rebuild
extern "main" [

	...args
]

# compile packages and dependencies
extern "go build" [

	...args
]

# remove object files
extern "go clean" [

	...args
]

# run godoc on package sources
extern "go doc" [

	...args
]

# print Go environment information
extern "go env" [

	...args
]

# run go tool fix on packages
extern "go fix" [

	...args
]

# run gofmt on package sources
extern "go fmt" [

	...args
]

# download and install packages and dependencies
extern "go get" [

	...args
]

# Generate runs commands described by directives within existing files.
extern "go generate" [

	...args
]

# get help on topic
extern "go help" [

	...args
]

# compile and install packages and dependencies
extern "go install" [

	...args
]

# list packages
extern "go list" [

	...args
]

# compile and run Go program
extern "go run" [

	...args
]

# test packages
extern "go test" [

	...args
]

# run specified go tool
extern "go tool" [

	...args
]

# target tool
extern "go addr2line api asm cgo compile dist fix link nm objdump pack pprof prof vet yacc" [

	...args
]

# print Go version
extern "go version" [

	...args
]

# vet packages
extern "go vet" [

	...args
]

# module maintenance
extern "go mod" [

	...args
]

# download modules to local cache
extern "go download" [

	...args
]

# edit go.mod from tools or scripts
extern "go edit" [

	...args
]

# print module requirement graph
extern "go graph" [

	...args
]

# initialize new module in current directory
extern "go init" [

	...args
]

# add missing and remove unused modules
extern "go tidy" [

	...args
]

# make vendored copy of dependencies
extern "go vendor" [

	...args
]

# verify dependencies have expected content
extern "go verify" [

	...args
]

# explain why packages or modules are needed
extern "go why" [

	...args
]

# Show examples in command line mode
extern "godoc" [
	--ex					# Show examples in command line mode
	--html					# Print HTML in command-line mode
	# --httptest.serve					# httptest.NewServer serves on this address and blocks
	--index					# Enable search index
	--index_files					# Glob pattern specifying index files
	--links					# Link identifiers to their declarations
	--play					# Enable playground in web interface
	--server					# Webserver address for command line searches
	--src					# Print (exported) source in command-line mode
	--timestamps					# Show timestamps with directory listings
	--help(-h)					# Show help
	...args
]

# Write cpu profile to this file
extern "gofmt" [
	--cpuprofile					# Write cpu profile to this file
	--help(-h)					# Show help
	...args
]

# Display diffs instead of rewriting files
extern "goimports" [
	--help(-h)					# Show help
	...args
]

# Set exit status to 1 if any issues are found
extern "golint" [
	--set_exit_status					# Set exit status to 1 if any issues are found
	--help(-h)					# Show help
	...args
]