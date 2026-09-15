# Hyprland systemwide operations

This repository manages the Hyprland 0.56.2 Lua session as a system-wide runtime while keeping its configuration in Chezmoi.

## Final layout

- Canonical configuration: `~/.config/hypr/hyprland.lua` (with its Lua modules beside it).
- GDM reads `/usr/share/wayland-sessions/hyprland.desktop`. Its `Exec` directly starts UWSM:
  `uwsm start -e -D Hyprland /usr/local/bin/start-hyprland -- --path /usr/local/bin/Hyprland -- --config /home/fwfurtado/.config/hypr/hyprland.lua`.
- The managed session hook intentionally installs that entry in `/usr/share/wayland-sessions`, replacing the Ubuntu package's generic Hyprland entry so the direct UWSM command wins. It removes only known stale managed entries.
- The promoted, root-owned prefix is `/opt/hyprland-0.56.2`.
- `/usr/local/bin/Hyprland`, `/usr/local/bin/start-hyprland`, and `/usr/local/bin/hyprctl` are symlinks into that prefix. `/usr/bin` is never overwritten.
- The Ubuntu session entry (`ubuntu.desktop`) is preserved; see the purge procedure below.

## Provenance and dependency boundary

The runtime is Hyprland commit `efb50993780079460b0cbed1363e2166a2de1d9f`, version `0.56.2`, with no plugins. The current installer **promotes an existing validated user prefix**; it does not compile Hyprland, Wayland, or any dependency.

The host supplies distro Wayland and common runtime libraries. Promotion copies only the selected Hyprland entry points and the custom runtime libraries needed by this build (`libaquamarine*`, `libhypr*.so*`, and `liblua5.5.so*`). Those copies exist because the current Ubuntu package versions do not satisfy every Hyprland minimum. The installer rewrites ELF RPATHs to `/opt/hyprland-0.56.2/lib` and audits the dependency closure. It does not change global `LD_LIBRARY_PATH` or `/etc/ld.so.conf`; any `LD_LIBRARY_PATH` used by the script is scoped to its private validation commands.

## First promotion

Install the promotion prerequisite before running the script:

```sh
sudo apt-get install patchelf
```

Run as the non-root build user with `sudo`; `SUDO_USER` must resolve to that user (the script uses that user's home, not `/root`). Before promotion, a complete, already validated source prefix is required at:

```text
$HOME/.local/opt/hyprland-0.56.2
```

For the invoking user, this is the same path the script computes as `$BUILD_HOME/.local/opt/hyprland-0.56.2`. It must contain executable `bin/Hyprland`, `bin/start-hyprland`, and `bin/hyprctl`, plus `bin/` and `lib/`. The source prefix is read-only input and is not deleted.

From the repository root, run the preflight first, then the real promotion:

```sh
sudo scripts/install-hyprland-systemwide.sh --dry-run
sudo scripts/install-hyprland-systemwide.sh --yes
```

`--dry-run` performs the checks without changing the filesystem, apt state, or source prefix. `--yes` confirms replacement of an existing `/opt/hyprland-0.56.2`; the old tree is moved to a timestamped `.rollback.*` path, not deleted. The installer also recreates the system portal preference and marks only its required runtime packages manual. It does not install or remove packages.

## Purging the Ubuntu package and restoring the session

The Ubuntu package owns a generic `hyprland.desktop`; `apt purge` can remove it, and it can also remove files that are not restored by a normal session selection. Before purging, preserve the Ubuntu entry if it exists:

```sh
if sudo test -e /usr/share/wayland-sessions/ubuntu.desktop; then
    sudo cp -a /usr/share/wayland-sessions/ubuntu.desktop \
        /root/ubuntu.desktop.before-hyprland-purge
fi
```

Purge without autoremove. Never use `apt autoremove` for this cutover:

```sh
sudo apt purge hyprland
```

Afterward, restore `ubuntu.desktop` if it was saved, and reapply this repository so the canonical Hyprland entry is installed again:

```sh
if sudo test -e /root/ubuntu.desktop.before-hyprland-purge; then
    sudo install -m 0644 /root/ubuntu.desktop.before-hyprland-purge \
        /usr/share/wayland-sessions/ubuntu.desktop
fi
chezmoi apply
```

AccountsService is not managed automatically by the installer or session hook. If GDM needs a per-user default, create or edit the user record and set `Session=hyprland`:

```sh
sudo install -d -m 0755 /var/lib/AccountsService/users
if sudo test -e "/var/lib/AccountsService/users/$USER"; then
    printf '%s\n' "Existing AccountsService record: preserve all existing keys and set Session=hyprland manually: /var/lib/AccountsService/users/$USER"
else
    printf '[User]\nSession=hyprland\n' | sudo tee "/var/lib/AccountsService/users/$USER" >/dev/null
fi
```

Do not replace an existing AccountsService file with the two-line example: preserve its other keys and sections.

## Validation

Run these checks after promotion and again after package purge/session restoration:

```sh
# Prefix exists, is executable, and is root-owned.
test -x /opt/hyprland-0.56.2/bin/Hyprland
stat -c '%U:%G %a %n' /opt/hyprland-0.56.2 /opt/hyprland-0.56.2/bin/Hyprland

# Public names resolve into the promoted prefix.
for name in Hyprland start-hyprland hyprctl; do
    readlink -f "/usr/local/bin/$name"
done

# Exact runtime version.
/usr/local/bin/Hyprland --version

# No missing libraries and no user-local source-prefix dependency.
ldd /opt/hyprland-0.56.2/bin/Hyprland
! ldd /opt/hyprland-0.56.2/bin/Hyprland 2>&1 | \
    grep -Eq 'not found|/\.local/opt/hyprland-0\.56\.2'

# GDM session and direct UWSM Exec.
grep -E '^(Name|TryExec|Exec|DesktopNames)=' \
    /usr/share/wayland-sessions/hyprland.desktop

# The distro Hyprland package is absent after purge (unknown-package output is OK).
if dpkg-query -W -f='${db:Status-Status}' hyprland 2>/dev/null | grep -qx installed; then
    printf '%s\n' 'hyprland package is still installed' >&2
    exit 1
else
    printf '%s\n' 'hyprland package is absent'
fi
```

Select **Hyprland** in GDM, log in, and verify the running session manually (for example, run `hyprctl version` and confirm the desktop is usable). The actual GDM login/reboot test is manual; the installer cannot prove it non-interactively.

## Updating 0.56.2

Prepare a new, fully validated Hyprland prefix outside Chezmoi at the required user-local path (or stage the version expected by a corresponding installer update), then rerun the promotion command. The promotion script cannot rebuild missing source or dependencies.

Distro-only development packages may block a 0.56.2 build: the observed minimums include `hyprutils >= 0.14.0`, `hyprgraphics >= 0.5.1`, and `wayland-protocols >= 1.49`. This guide does not prescribe an unimplemented workaround; provide a validated prefix before promotion.

Do not delete the user-local source prefix until the promoted prefix has passed the version, `ldd`, session, and manual login checks.

## Rollback

Promotion keeps previous trees as `/opt/hyprland-0.56.2.rollback.*`. If a new tree fails validation or login, retain it for diagnosis under a failed name and restore one known rollback tree:

```sh
sudo mv /opt/hyprland-0.56.2 \
    "/opt/hyprland-0.56.2.failed.$(date -u +%Y%m%dT%H%M%SZ)"
rollback_prefix="$(printf '%s\n' /opt/hyprland-0.56.2.rollback.* | sort | tail -n 1)"
sudo test -d "$rollback_prefix"
sudo mv -- "$rollback_prefix" /opt/hyprland-0.56.2
for name in Hyprland start-hyprland hyprctl; do
    sudo ln -sfn "/opt/hyprland-0.56.2/bin/$name" "/usr/local/bin/$name"
done
```

The `rollback_prefix` command selects the lexically newest preserved tree; inspect it and choose another `.rollback.*` directory if needed. Restore the canonical session with `chezmoi apply`; restore a `.rollback.*` portal preference under `/usr/share/xdg-desktop-portal/` if the portal must be reverted. Roll back configuration source through Git (revert or check out the appropriate config commit), then apply it; do not edit a second undocumented config in place.

No runnable Hyprland 0.53 fallback is retained. A rollback means restoring a preserved, validated prefix or fixing the current one—not selecting an unmaintained fallback binary.

## Policy

- Never run `apt autoremove` as part of this installation or purge.
- Never overwrite `/usr/bin`.
- Never delete the user-local validated source until manual login is validated.
- System promotion, package purge, and rollback are manual operations outside normal `chezmoi apply`; Chezmoi manages the canonical Lua source and the GDM session hook, not the privileged promotion.
