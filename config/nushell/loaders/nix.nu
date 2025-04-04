use std

export-env {
  $env.NIX_PROFILES = $"/nix/var/nix/profiles/default ($env.HOME)/.nix-profile"
  $env.XDG_DATA_DIRS = $"( if ($env.XDG_DATA_DIRS | is-empty) {"/usr/local/share:/usr/share:/nix/var/nix/profiles/default/share"} else {$env.XDG_DATA_DIRS}):/nix/var/nix/profiles/default/share"
  $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"


  std path add "/nix/var/nix/profiles/default/bin"
  std path add $"($env.HOME)/.nix-profile/bin"
}