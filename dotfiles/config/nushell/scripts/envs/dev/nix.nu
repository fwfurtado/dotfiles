use std

export-env {
    let NIX_LINK = ($env | get HOME | path join '.nix-profile')

    load-env {
        NIX_PROFILES: $"/nix/var/nix/profiles/default ($NIX_LINK)"
        NIX_SSL_CERT_FILE: /etc/ssl/certs/ca-certificates.crt
        XDG_DATA_DIRS: $"($env.XDG_DATA_DIRS):($NIX_LINK | path join '/share'):/nix/var/nix/profiles/default/share"
    }

    std path add ($NIX_LINK | path join 'bin')
}