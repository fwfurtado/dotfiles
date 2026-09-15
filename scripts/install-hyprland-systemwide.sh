#!/usr/bin/env bash
# Promote the validated Hyprland build into a versioned, root-owned prefix.
# Run as: sudo scripts/install-hyprland-systemwide.sh [--dry-run|--yes]
set -Eeuo pipefail

readonly VERSION='0.56.2'
readonly PREFIX="/opt/hyprland-${VERSION}"
readonly PORTAL_FILE='/usr/share/xdg-desktop-portal/hyprland-portals.conf'
readonly PUBLIC_BIN_DIR='/usr/local/bin'
readonly ROLLBACK_TAG="$(printf '%(%Y%m%dT%H%M%SZ)T' -1)-$$"

DRY_RUN=0
ASSUME_YES=0
BUILD_USER=''
BUILD_HOME=''
SOURCE_PREFIX=''
WORKSPACE=''
STAGED_PREFIX=''
FINAL_STAGING=''
PORTAL_TEMP=''
rollback_prefix=''

log() {
    printf '[hyprland-install] %s\n' "$*"
}

warn() {
    printf '[hyprland-install] warning: %s\n' "$*" >&2
}

die() {
    printf '[hyprland-install] error: %s\n' "$*" >&2
    exit 1
}

on_error() {
    local status=$?
    printf '[hyprland-install] error: command failed at line %s (status %s).\n' "${BASH_LINENO[0]}" "$status" >&2
    printf '%s\n' 'Review the command output above; no apt purge/autoremove or user-local files are removed.' >&2
    exit "$status"
}

cleanup() {
    local status=$?
    if [[ -n "$WORKSPACE" && -d "$WORKSPACE" ]]; then
        rm -rf -- "$WORKSPACE"
    fi
    if [[ -n "$FINAL_STAGING" && -d "$FINAL_STAGING" ]]; then
        rm -rf -- "$FINAL_STAGING"
    fi
    if [[ -n "$PORTAL_TEMP" && -e "$PORTAL_TEMP" ]]; then
        rm -f -- "$PORTAL_TEMP"
    fi
    return "$status"
}

trap on_error ERR
trap cleanup EXIT

usage() {
    printf '%s\n' \
        'Usage: sudo scripts/install-hyprland-systemwide.sh [OPTIONS]' \
        '' \
        "Promote the validated Hyprland $VERSION prefix to $PREFIX, then atomically" \
        'publish /usr/local/bin/Hyprland, start-hyprland, and hyprctl.' \
        '' \
        'Options:' \
        '  --dry-run       Run preflight checks and show changes; do not install.' \
        '  --yes, -y       Confirm replacement of an existing target prefix.' \
        '  --help, -h      Show this help.'
}

while (($#)); do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        --yes|-y) ASSUME_YES=1 ;;
        --help|-h) usage; exit 0 ;;
        *) die "unknown option '$1' (use --help)" ;;
    esac
    shift
done

[[ "$EUID" -eq 0 ]] || die "run this script as sudo so SUDO_USER identifies the non-root build user"
[[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]] || die "SUDO_USER is missing; invoke it as 'sudo $0', not from a root shell"

# Promotion does not build anything. These are the only external tools used by
# the preflight, staging, dynamic-link audit, and atomic installation paths.
readonly REQUIRED_COMMANDS=(
    patchelf readelf ldd file find cp mv install mktemp cmp stat id grep
    dpkg-query apt-mark runuser getent chown ln rm chmod
)

if ! command -v patchelf >/dev/null 2>&1; then
    die "patchelf is required to remove the user-local RUNPATH; install it with 'apt-get install patchelf'"
fi
for command_name in "${REQUIRED_COMMANDS[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || die "required command '$command_name' is unavailable"
done

BUILD_USER="$SUDO_USER"
passwd_entry="$(getent passwd "$BUILD_USER")" || die "cannot resolve SUDO_USER=$BUILD_USER"
IFS=: read -r _ _ _ _ _ BUILD_HOME _ <<<"$passwd_entry"
[[ -n "$BUILD_HOME" && -d "$BUILD_HOME" ]] || die "cannot resolve a home directory for SUDO_USER=$BUILD_USER"
[[ "$BUILD_HOME" == /* ]] || die "resolved SUDO_USER home is not an absolute path: $BUILD_HOME"
SOURCE_PREFIX="$BUILD_HOME/.local/opt/hyprland-${VERSION}"
readonly BUILD_USER BUILD_HOME SOURCE_PREFIX

# The validated prefix is user-local and must remain untouched. Only the
# selected public entry points and custom Hypr runtime libraries are promoted;
# Wayland and ordinary dependencies remain distro-owned and are resolved from
# the host runtime.
[[ -d "$SOURCE_PREFIX" ]] || die "validated source prefix is missing: $SOURCE_PREFIX"
[[ -d "$SOURCE_PREFIX/bin" && -d "$SOURCE_PREFIX/lib" ]] || die "validated source prefix lacks bin/ or lib/: $SOURCE_PREFIX"
for public_binary in Hyprland start-hyprland hyprctl; do
    [[ -x "$SOURCE_PREFIX/bin/$public_binary" ]] || die "validated source prefix lacks executable bin/$public_binary"
done
build_uid="$(id -u "$BUILD_USER")" || die "cannot determine uid for SUDO_USER=$BUILD_USER"
source_user_uid="$(runuser -u "$BUILD_USER" -- id -u)" || die "cannot execute source preflight as SUDO_USER=$BUILD_USER"
[[ "$source_user_uid" == "$build_uid" ]] || die "runuser uid does not match SUDO_USER=$BUILD_USER"

for package_name in xdg-desktop-portal-hyprland libhyprcursor0; do
    if ! dpkg-query -W -f='${db:Status-Status}' "$package_name" 2>/dev/null | grep -qx installed; then
        die "required runtime package '$package_name' is not installed; install it separately, then rerun (this script only marks these packages manual)"
    fi
done

[[ -d /opt ]] || die '/opt is unavailable for a root-owned installation'
if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
    if [[ "$DRY_RUN" -eq 0 && "$ASSUME_YES" -eq 0 ]]; then
        if [[ ! -t 0 ]]; then
            die "existing $PREFIX would be replaced; rerun interactively or pass --yes (the old tree is retained as a rollback copy)"
        fi
        printf 'Replace existing %s and retain it as a rollback copy? [y/N] ' "$PREFIX" >&2
        read -r answer
        [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]] || die 'replacement cancelled'
    fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    log 'preflight succeeded; dry-run makes no filesystem, apt, or source changes'
    log "would promote the validated prefix $SOURCE_PREFIX to $PREFIX and use distro Wayland/runtime libraries"
    if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
        log "would move $PREFIX to a unique ${PREFIX}.rollback.* path"
    fi
    log "would atomically publish $PUBLIC_BIN_DIR/{Hyprland,start-hyprland,hyprctl}"
    log "would recreate $PORTAL_FILE and mark only xdg-desktop-portal-hyprland and libhyprcursor0 manual"
    exit 0
fi

# Stage under /opt as root only after the complete source preflight. The source
# tree is read-only input and is never deleted or modified by cleanup.
WORKSPACE="$(mktemp -d "/opt/.hyprland-${VERSION}.stage.XXXXXX")" || die 'could not create an isolated root staging directory under /opt'
STAGED_PREFIX="$WORKSPACE"
FINAL_STAGING="$STAGED_PREFIX"
readonly WORKSPACE STAGED_PREFIX
install -d -o root -g root -m 0755 "$STAGED_PREFIX/bin" "$STAGED_PREFIX/lib"

for public_binary in Hyprland start-hyprland hyprctl; do
    cp -a -- "$SOURCE_PREFIX/bin/$public_binary" "$STAGED_PREFIX/bin/" || die "could not stage bin/$public_binary"
done

staged_library_count=0
while IFS= read -r -d '' library; do
    cp -a -- "$library" "$STAGED_PREFIX/lib/" || die "could not stage runtime library $library"
    staged_library_count=$((staged_library_count + 1))
done < <(
    find "$SOURCE_PREFIX/lib" -maxdepth 1 \( -type f -o -type l \) \( \
        -name 'libaquamarine*' -o -name 'libhypr*.so*' -o -name 'liblua5.5.so*' \
    \) -print0
)
[[ "$staged_library_count" -gt 0 ]] || die 'validated source prefix contains none of the required custom runtime libraries'

# Replace every ELF's RPATH rather than inheriting the user-local source path.
# Shell scripts and symlinks are deliberately excluded: only regular ELF files
# in the staged bin/lib directories receive the final prefix-local RPATH.
patch_and_audit_elf() {
    local tree=$1 artifact file_info dynamic_info
    while IFS= read -r -d '' artifact; do
        file_info="$(file -b -- "$artifact")"
        if grep -q 'ELF' <<<"$file_info"; then
            patchelf --set-rpath "$PREFIX/lib" "$artifact" || die "could not set the staged RPATH on $artifact"
            dynamic_info="$(readelf -d "$artifact" 2>&1)" || die "cannot inspect staged ELF $artifact"
            grep -Fq "Library runpath: [$PREFIX/lib]" <<<"$dynamic_info" || die "staged ELF $artifact lacks the final RPATH $PREFIX/lib"
            if grep -Fq "$BUILD_HOME/.local/opt" <<<"$dynamic_info" || grep -Fq "$WORKSPACE" <<<"$dynamic_info"; then
                die "staged ELF $artifact contains a user-local or workspace path"
            fi
        fi
    done < <(find "$tree/bin" "$tree/lib" -maxdepth 1 -type f -print0)
}
patch_and_audit_elf "$STAGED_PREFIX"

validate_closure() {
    local tree=$1 temporary_library_path=$2 artifact file_info dynamic_info closure
    while IFS= read -r -d '' artifact; do
        file_info="$(file -b -- "$artifact")"
        if grep -q 'ELF' <<<"$file_info"; then
            if ! dynamic_info="$(readelf -d "$artifact" 2>&1)"; then
                printf '[hyprland-install] error: cannot inspect ELF %s\n' "$artifact" >&2
                return 1
            fi
            if ! grep -Fq "Library runpath: [$PREFIX/lib]" <<<"$dynamic_info"; then
                printf '[hyprland-install] error: ELF %s lacks the final RPATH %s/lib\n' "$artifact" "$PREFIX" >&2
                return 1
            fi
            if [[ "$temporary_library_path" -eq 1 ]]; then
                closure="$(LD_LIBRARY_PATH="$tree/lib" ldd "$artifact" 2>&1 || true)"
            else
                closure="$(ldd "$artifact" 2>&1 || true)"
            fi
            if grep -q 'not found' <<<"$closure" || grep -Fq "$BUILD_HOME/.local/opt" <<<"$closure" || grep -Fq "$WORKSPACE" <<<"$closure"; then
                printf '[hyprland-install] error: dependency closure for %s is incomplete or points at a user-local/workspace path\n' "$artifact" >&2
                return 1
            fi
        fi
    done < <(find "$tree/bin" "$tree/lib" -maxdepth 1 -type f -print0)
}


# The temporary library path is scoped to this pre-install ldd invocation only.
validate_closure "$STAGED_PREFIX" 1
if ! version_output="$(LD_LIBRARY_PATH="$STAGED_PREFIX/lib" "$STAGED_PREFIX/bin/Hyprland" --version 2>&1)"; then
    die 'staged Hyprland could not execute --version'
fi
if ! grep -Eq "^Hyprland[[:space:]]+$VERSION([[:space:]]|$)" <<<"$version_output"; then
    die "staged Hyprland did not report exactly version $VERSION: $version_output"
fi
# Make the complete staged tree root-owned before the atomic rename.
chown -R root:root "$STAGED_PREFIX" || die 'could not make the staged tree root-owned'
[[ "$(stat -c '%u' "$STAGED_PREFIX")" == 0 ]] || die 'staged tree is not root-owned'


# A pre-existing prefix is moved, never deleted. This retains every previous
# rollback copy and allows an interrupted replacement to be recovered.
if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
    rollback_prefix="$PREFIX.rollback.$ROLLBACK_TAG"
    while [[ -e "$rollback_prefix" || -L "$rollback_prefix" ]]; do
        rollback_prefix="$PREFIX.rollback.$ROLLBACK_TAG.$RANDOM"
    done
    mv -- "$PREFIX" "$rollback_prefix" || die "cannot preserve existing $PREFIX at $rollback_prefix"
    log "preserved previous prefix as $rollback_prefix"
fi
if ! mv -- "$FINAL_STAGING" "$PREFIX"; then
    if [[ -n "$rollback_prefix" && ( -e "$rollback_prefix" || -L "$rollback_prefix" ) ]]; then
        mv -- "$rollback_prefix" "$PREFIX" 2>/dev/null || true
    fi
    die "cannot atomically place the staged prefix at $PREFIX"
fi
FINAL_STAGING=''

if ! chown -R root:root "$PREFIX"; then
    failed_prefix="$PREFIX.failed.$ROLLBACK_TAG"
    mv -- "$PREFIX" "$failed_prefix" 2>/dev/null || true
    if [[ -n "$rollback_prefix" && ( -e "$rollback_prefix" || -L "$rollback_prefix" ) ]]; then
        mv -- "$rollback_prefix" "$PREFIX" 2>/dev/null || true
    fi
    die "cannot make installed prefix root-owned; failed tree retained as $failed_prefix"
fi
[[ "$(stat -c '%u' "$PREFIX")" == 0 ]] || die "installed prefix is not root-owned"

restore_old_prefix() {
    local failed="$PREFIX.failed.$ROLLBACK_TAG"
    if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
        mv -- "$PREFIX" "$failed" 2>/dev/null || true
    fi
    if [[ -n "$rollback_prefix" && ( -e "$rollback_prefix" || -L "$rollback_prefix" ) ]]; then
        mv -- "$rollback_prefix" "$PREFIX" 2>/dev/null || true
        warn "new prefix failed validation and was retained as $failed; restored $PREFIX"
    else
        warn "new prefix failed validation and was retained as $failed"
    fi
}

# Repeat the closure checks against the real /opt tree before publishing any
# stable command names. System Wayland paths are intentionally allowed here.
if ! validate_closure "$PREFIX" 0; then
    restore_old_prefix
    die 'installed dynamic closure validation failed'
fi
if ! version_output="$("$PREFIX/bin/Hyprland" --version 2>&1)" || ! grep -Eq "^Hyprland[[:space:]]+$VERSION([[:space:]]|$)" <<<"$version_output"; then
    restore_old_prefix
    die "installed Hyprland did not report exactly version $VERSION: $version_output"
fi

install -d -o root -g root -m 0755 "$PUBLIC_BIN_DIR"
for public_binary in Hyprland start-hyprland hyprctl; do
    temporary_link="$PUBLIC_BIN_DIR/.${public_binary}.hyprland-install.$$"
    rm -f -- "$temporary_link"
    ln -s "$PREFIX/bin/$public_binary" "$temporary_link"
    mv -Tf -- "$temporary_link" "$PUBLIC_BIN_DIR/$public_binary"
done

# Recreate the validated system preference atomically. Preserve an existing
# differing file under a unique rollback name rather than overwriting it.
portal_dir="${PORTAL_FILE%/*}"
install -d -o root -g root -m 0755 "$portal_dir"
portal_temp="$(mktemp "$portal_dir/.hyprland-portals.conf.XXXXXX")"
PORTAL_TEMP="$portal_temp"
printf '%s\n' \
    '[preferred]' \
    'default=hyprland;gtk' \
    'org.freedesktop.impl.portal.ScreenCast=hyprland' \
    'org.freedesktop.impl.portal.Screenshot=hyprland' \
    'org.freedesktop.impl.portal.FileChooser=gtk' \
    'org.freedesktop.impl.portal.Print=gtk' \
    'org.freedesktop.impl.portal.AppChooser=gtk' \
    'org.freedesktop.impl.portal.Secret=gnome-keyring' \
    'org.freedesktop.impl.portal.GlobalShortcuts=hyprland' >"$portal_temp"
if [[ -e "$PORTAL_FILE" || -L "$PORTAL_FILE" ]] && ! cmp -s "$portal_temp" "$PORTAL_FILE"; then
    portal_rollback="$PORTAL_FILE.rollback.$ROLLBACK_TAG"
    while [[ -e "$portal_rollback" || -L "$portal_rollback" ]]; do
        portal_rollback="$PORTAL_FILE.rollback.$ROLLBACK_TAG.$RANDOM"
    done
    cp -a -- "$PORTAL_FILE" "$portal_rollback" || die "cannot preserve existing portal preference at $portal_rollback"
    log "preserved previous portal preference as $portal_rollback"
fi
chown root:root "$portal_temp"
chmod 0644 "$portal_temp"
mv -Tf -- "$portal_temp" "$PORTAL_FILE"
PORTAL_TEMP=''

# This is the only apt state change: protect exactly the two runtime packages
# that otherwise may become autoremove candidates. No package is installed or
# removed here.
apt-mark manual xdg-desktop-portal-hyprland libhyprcursor0 >/dev/null || die 'apt-mark manual failed; verify both runtime packages are installed'

log "Hyprland $VERSION promoted from $SOURCE_PREFIX to $PREFIX"
log 'public symlinks, portal preference, and minimal apt protection are ready'
