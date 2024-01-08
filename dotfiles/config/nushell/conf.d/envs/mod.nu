use std


def add-to-path [$path: string] { std path add $path }
def from-home [$path: string] { $env.HOME | path join $path }
def from-env [$env_name: string, $path: string] { $env_name | path join $path }

# Base
export-env {
    $env.SYSTEMD_EDITOR = 'nvim'
    $env.SUDO_EDITOR = 'nvim'
    $env.EDITOR = 'nvim'
    $env.VISUAL = 'nvim'
    $env.LS_COLORS = (vivid generate one-dark | str trim)

    $env.FZF_DEFAULT_OPTS = '--height 40% --no-bold --layout reverse --border'
    $env.GPG_TTY = (tty)
}

# Android settings
export-env {
    $env.ANDROID_SDK = (from-home "Android/Sdk")

    add-to-path (from-env $env.ANDROID_SDK 'tools')
    add-to-path (from-env $env.ANDROID_SDK 'tools/bin')
    add-to-path (from-env $env.ANDROID_SDK 'platform-tools')
}

# Dotnet settings
export-env {
    $env.DOTNET_ROOT = (from-home '.dotnet')
    add-to-path (from-env $env.DOTNET_ROOT 'tools')
}

# Golang settings
export-env {
    $env.GOPATH = (from-home 'go')
    add-to-path (from-env $env.GOPATH 'bin')
}

# Erlang/Elixir settings
export-env {
    $env.ERL_AFLAGS = '-kernel shell_history enabled'
}

# Rust settings
export-env {
    $env.CARGO_HOME = (from-home '.cargo')
    add-to-path (from-env $env.CARGO_HOME 'bin')
}

# Haskell settings
export-env {
    add-to-path (from-home '.cabal/bin')
    add-to-path (from-home '.ghcup/bin')
}

# Pulumi settings
export-env {
    add-to-path (from-home '.pulumi/bin')
}

# Krew settings
export-env {
    add-to-path (from-home '.krew/bin')
}

# Path
export-env {
    add-to-path '/usr/local/bin' # only for ubuntu ¯\_(ツ)_/¯
    add-to-path (from-home '.local/bin')
    add-to-path (from-home 'bin') # I don't remember why I have this
}