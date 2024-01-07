# Set exit status to 1 if any issues are found
export extern "golint" [
	--set_exit_status					# Set exit status to 1 if any issues are found
	--help(-h)					# Show help
	...args
]