# Nushell Environment Config File

def create_left_prompt [] {
    let path_segment = if (is-admin) {
        $"(ansi red_bold)($env.PWD)"
    } else {
        $"(ansi green_bold)($env.PWD)"
    }

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%m/%d/%Y %r')
    ] | str join)

    $time_segment
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = { "〉" }
$env.PROMPT_INDICATOR_VI_INSERT = { ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = { "〉" }
$env.PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# Go settings
#export GOROOT=(asdf where golang)/go/bin
$env.GOPATH = ($env.HOME | path join 'go')
$env.GOPRIVATE = "go.buf.build"

# Erlang settings 
$env.ERL_AFLAGS = '-kernel shell_history enabled'

# Dotnet settings
$env.DOTNET_ROOT = ( $env.HOME | path join '.dotnet' )

# Android settings
$env.ANDROID_SDK = ( $env.HOME | path join 'Android/Sdk' )

$env.SYSTEMD_EDITOR = 'nvim'
$env.SUDO_EDITOR = 'nvim'
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'
$env.LS_COLORS = (vivid generate one-dark | str trim)

$env.FZF_DEFAULT_OPTS = '--height 40% --no-bold --layout reverse --border'
$env.GPG_TTY = (tty)

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.PATH = ($env.PATH | append '/usr/local/bin')
$env.PATH = ($env.PATH | append '/var/lib/snapd/bin')

$env.PATH = ($env.PATH | append ($env.ANDROID_SDK | path join 'tools') )
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK | path join 'tools/bin') )
$env.PATH = ($env.PATH | append ($env.ANDROID_SDK | path join 'platform-tools') )

$env.PATH = ($env.PATH | append '~/bin')
$env.PATH = ($env.PATH | append '~/.local/bin')
$env.PATH = ($env.PATH | append '~/.cargo/bin')

$env.PATH = ($env.PATH | append $env.DOTNET_ROOT  )
$env.PATH = ($env.PATH | append ($env.DOTNET_ROOT | path join 'tools') )

$env.PATH = ($env.PATH | append '~/go/bin')
$env.PATH = ($env.PATH | append '~/.ghcup/bin')
$env.PATH = ($env.PATH | append '~/.cabal/bin')

$env.PATH = ($env.PATH | append '~/.pulumi/bin')
$env.PATH = ($env.PATH | append '~/.krew/bin')


