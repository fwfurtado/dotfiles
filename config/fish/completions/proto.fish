# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_proto_global_optspecs
	string join \n c/config-mode= dump log= y/yes json h/help V/version
end

function __fish_proto_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_proto_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_proto_using_subcommand
	set -l cmd (__fish_proto_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c proto -n "__fish_proto_needs_command" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_needs_command" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_needs_command" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_needs_command" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_needs_command" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_needs_command" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_needs_command" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_needs_command" -f -a "activate" -d 'Activate proto for the current shell session by prepending tool directories to PATH and setting environment variables.'
complete -c proto -n "__fish_proto_needs_command" -f -a "alias" -d 'Add an alias to a tool.'
complete -c proto -n "__fish_proto_needs_command" -f -a "bin" -d 'Display the absolute path to a tools executable.'
complete -c proto -n "__fish_proto_needs_command" -f -a "clean" -d 'Clean the ~/.proto directory by removing stale tools, plugins, and files.'
complete -c proto -n "__fish_proto_needs_command" -f -a "completions" -d 'Generate command completions for your current shell.'
complete -c proto -n "__fish_proto_needs_command" -f -a "debug" -d 'Debug the current proto environment.'
complete -c proto -n "__fish_proto_needs_command" -f -a "diagnose" -d 'Diagnose potential issues with your proto installation.'
complete -c proto -n "__fish_proto_needs_command" -f -a "install" -d 'Download and install one or many tools.'
complete -c proto -n "__fish_proto_needs_command" -f -a "migrate" -d 'Migrate breaking changes for the proto installation.'
complete -c proto -n "__fish_proto_needs_command" -f -a "outdated" -d 'Check if configured tool versions are out of date.'
complete -c proto -n "__fish_proto_needs_command" -f -a "pin" -d 'Pin a global or local version of a tool.'
complete -c proto -n "__fish_proto_needs_command" -f -a "plugin" -d 'Operations for managing tool plugins.'
complete -c proto -n "__fish_proto_needs_command" -f -a "regen" -d 'Regenerate shims and optionally relink bins.'
complete -c proto -n "__fish_proto_needs_command" -f -a "run" -d 'Run a tool after detecting a version from the environment.'
complete -c proto -n "__fish_proto_needs_command" -f -a "setup" -d 'Setup proto for your current shell by injecting exports and updating PATH.'
complete -c proto -n "__fish_proto_needs_command" -f -a "status" -d 'List all configured tools and their current installation status.'
complete -c proto -n "__fish_proto_needs_command" -f -a "unalias" -d 'Remove an alias from a tool.'
complete -c proto -n "__fish_proto_needs_command" -f -a "uninstall" -d 'Uninstall a tool.'
complete -c proto -n "__fish_proto_needs_command" -f -a "unpin" -d 'Unpin a global or local version of a tool.'
complete -c proto -n "__fish_proto_needs_command" -f -a "upgrade" -d 'Upgrade proto to the latest version.'
complete -c proto -n "__fish_proto_needs_command" -f -a "versions" -d 'List available versions for a tool.'
complete -c proto -n "__fish_proto_using_subcommand activate" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand activate" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand activate" -l export -d 'Print the activate instructions in shell specific-syntax'
complete -c proto -n "__fish_proto_using_subcommand activate" -l no-bin -d 'Don\'t include ~/.proto/bin in path lookup'
complete -c proto -n "__fish_proto_using_subcommand activate" -l no-shim -d 'Don\'t include ~/.proto/shims in path lookup'
complete -c proto -n "__fish_proto_using_subcommand activate" -l on-init -d 'Run activate hook on initialization and export'
complete -c proto -n "__fish_proto_using_subcommand activate" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand activate" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand activate" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand activate" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand activate" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand alias" -l to -d 'Location of .prototools to add to' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand alias" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand alias" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand alias" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand alias" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand alias" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand alias" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand alias" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand bin" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand bin" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand bin" -l bin -d 'Display symlinked binary path when available'
complete -c proto -n "__fish_proto_using_subcommand bin" -l shim -d 'Display shim path when available'
complete -c proto -n "__fish_proto_using_subcommand bin" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand bin" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand bin" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand bin" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand bin" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand clean" -l days -d 'Clean tools and plugins older than the specified number of days' -r
complete -c proto -n "__fish_proto_using_subcommand clean" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand clean" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand clean" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand clean" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand clean" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand clean" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand clean" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand completions" -l shell -d 'Shell to generate for' -r
complete -c proto -n "__fish_proto_using_subcommand completions" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand completions" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand completions" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand completions" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand completions" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand completions" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand completions" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -f -a "config" -d 'Debug all loaded .prototools config\'s for the current directory.'
complete -c proto -n "__fish_proto_using_subcommand debug; and not __fish_seen_subcommand_from config env" -f -a "env" -d 'Debug the current proto environment and store.'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from config" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand debug; and __fish_seen_subcommand_from env" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand diagnose" -l shell -d 'Shell to diagnose for' -r
complete -c proto -n "__fish_proto_using_subcommand diagnose" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand diagnose" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand diagnose" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand diagnose" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand diagnose" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand diagnose" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand diagnose" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand install" -l pin -d 'Pin the resolved version to .prototools' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand install" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand install" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand install" -l build -d 'Build from source instead of downloading a pre-built'
complete -c proto -n "__fish_proto_using_subcommand install" -l no-build -d 'Download a pre-built instead of building from source'
complete -c proto -n "__fish_proto_using_subcommand install" -l canary -d 'When installing one tool, use a canary (nightly, etc) version'
complete -c proto -n "__fish_proto_using_subcommand install" -l force -d 'Force reinstallation even if it is already installed'
complete -c proto -n "__fish_proto_using_subcommand install" -l internal
complete -c proto -n "__fish_proto_using_subcommand install" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand install" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand install" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand install" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand install" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand migrate" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand migrate" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand migrate" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand migrate" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand migrate" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand migrate" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand migrate" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand outdated" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand outdated" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand outdated" -l latest -d 'When updating versions, use the latest version instead of newest'
complete -c proto -n "__fish_proto_using_subcommand outdated" -l update -d 'Update and write the versions to their respective configuration'
complete -c proto -n "__fish_proto_using_subcommand outdated" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand outdated" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand outdated" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand outdated" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand outdated" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand pin" -l to -d 'Location of .prototools to pin to' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand pin" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand pin" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand pin" -l resolve -d 'Resolve the version before pinning'
complete -c proto -n "__fish_proto_using_subcommand pin" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand pin" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand pin" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand pin" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand pin" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -f -a "add" -d 'Add a plugin to manage a tool.'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -f -a "info" -d 'Display information about an installed plugin and its inventory.'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -f -a "list" -d 'List all configured and built-in plugins, and optionally include inventory.'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -f -a "remove" -d 'Remove a plugin and unmanage a tool.'
complete -c proto -n "__fish_proto_using_subcommand plugin; and not __fish_seen_subcommand_from add info list remove search" -f -a "search" -d 'Search for available plugins provided by the community.'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -l to -d 'Location of .prototools to add to' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from add" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from info" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -l aliases -d 'Include resolved aliases in the output'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -l versions -d 'Include installed versions in the output'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from list" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l from -d 'Location of .prototools to remove from' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from remove" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand plugin; and __fish_seen_subcommand_from search" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand regen" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand regen" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand regen" -l bin -d 'Also recreate binary symlinks'
complete -c proto -n "__fish_proto_using_subcommand regen" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand regen" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand regen" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand regen" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand regen" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand run" -l alt -d 'Name of an alternate (secondary) binary to run' -r
complete -c proto -n "__fish_proto_using_subcommand run" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand run" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand run" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand run" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand run" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand run" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand setup" -l shell -d 'Shell to setup for' -r
complete -c proto -n "__fish_proto_using_subcommand setup" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand setup" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand setup" -l no-modify-profile -d 'Don\'t update a shell profile'
complete -c proto -n "__fish_proto_using_subcommand setup" -l no-modify-path -d 'Don\'t update the system path'
complete -c proto -n "__fish_proto_using_subcommand setup" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand setup" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand setup" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand setup" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand setup" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand status" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand status" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand status" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand status" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand status" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand status" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand status" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand unalias" -l from -d 'Location of .prototools to remove from' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand unalias" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand unalias" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand unalias" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand unalias" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand unalias" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand unalias" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand unalias" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand uninstall" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand uninstall" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand uninstall" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand uninstall" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand uninstall" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand uninstall" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand uninstall" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand unpin" -l from -d 'Location of .prototools to unpin from' -r -f -a "global\t''
local\t''
user\t''"
complete -c proto -n "__fish_proto_using_subcommand unpin" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand unpin" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand unpin" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand unpin" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand unpin" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand unpin" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand unpin" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand upgrade" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand upgrade" -l check -d 'Check versions only and avoid upgrading'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -s h -l help -d 'Print help'
complete -c proto -n "__fish_proto_using_subcommand upgrade" -s V -l version -d 'Print version'
complete -c proto -n "__fish_proto_using_subcommand versions" -s c -l config-mode -d 'Mode in which to load configuration' -r -f -a "global\t''
local\t''
upwards\t''
upwards-global\t''"
complete -c proto -n "__fish_proto_using_subcommand versions" -l log -d 'Lowest log level to output' -r -f -a "off\t''
error\t''
warn\t''
info\t''
debug\t''
trace\t''
verbose\t''"
complete -c proto -n "__fish_proto_using_subcommand versions" -l aliases -d 'Include aliases in the output'
complete -c proto -n "__fish_proto_using_subcommand versions" -l installed -d 'Only display installed versions'
complete -c proto -n "__fish_proto_using_subcommand versions" -l dump -d 'Dump a trace profile to the working directory'
complete -c proto -n "__fish_proto_using_subcommand versions" -s y -l yes -d 'Avoid all interactive prompts and use defaults'
complete -c proto -n "__fish_proto_using_subcommand versions" -l json -d 'Print as JSON (when applicable)'
complete -c proto -n "__fish_proto_using_subcommand versions" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c proto -n "__fish_proto_using_subcommand versions" -s V -l version -d 'Print version'
