#!/usr/bin/env bash
# Promote the validated Hyprland build into a versioned, root-owned prefix.
# Run as: sudo scripts/install-hyprland-systemwide.sh [--dry-run|--yes]
set -Eeuo pipefail

readonly VERSION='0.56.2'
readonly HYPRLAND_COMMIT='efb50993780079460b0cbed1363e2166a2de1d9f'
readonly PREFIX="/opt/hyprland-${VERSION}"
readonly PORTAL_FILE='/usr/share/xdg-desktop-portal/hyprland-portals.conf'
readonly PUBLIC_BIN_DIR='/usr/local/bin'
readonly ROLLBACK_TAG="$(date -u +%Y%m%dT%H%M%SZ)-$$"

DRY_RUN=0
ASSUME_YES=0
BUILD_USER=''
BUILD_HOME=''
WORKSPACE=''
STAGE=''
BUILD_PREFIX=''
STAGED_PREFIX=''
PORTAL_TEMP=''
FINAL_STAGING=''

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
    cat <<'EOF'
Usage: sudo scripts/install-hyprland-systemwide.sh [OPTIONS]

Build and install Hyprland 0.56.2 at /opt/hyprland-0.56.2, then atomically
publish /usr/local/bin/Hyprland, start-hyprland, and hyprctl.

Options:
  --dry-run       Run preflight checks and show changes; do not build or install.
  --yes, -y       Confirm replacement of an existing target prefix.
  --help, -h      Show this help.
EOF
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
command -v getent >/dev/null 2>&1 || die 'getent is required to resolve SUDO_USER'

BUILD_USER="$SUDO_USER"
BUILD_HOME="$(getent passwd "$BUILD_USER" | cut -d: -f6)"
[[ -n "$BUILD_HOME" && -d "$BUILD_HOME" ]] || die "cannot resolve a home directory for SUDO_USER=$BUILD_USER"
[[ "$BUILD_HOME" == /* ]] || die "resolved SUDO_USER home is not an absolute path: $BUILD_HOME"

readonly BUILD_USER BUILD_HOME

# These are deliberately checks, not package installation. The validated build
# used the following toolchain and system development headers. Install missing
# packages separately; this script never changes the apt package set except for
# the two explicit manual marks performed after a successful installation.
readonly REQUIRED_COMMANDS=(
    git cmake meson pkg-config gcc g++ make readelf ldd file find stat id nproc grep
    runuser install mktemp cmp dpkg-query apt-mark
)
if ! command -v ninja >/dev/null 2>&1; then
    die "required build backend 'ninja' is unavailable; install ninja-build (this validated build has no supported CMake backend fallback)"
fi
for command_name in "${REQUIRED_COMMANDS[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || die "required build command '$command_name' is unavailable; install build-essential, cmake, ninja-build, meson, pkg-config, binutils, file, and util-linux first"
done
BUILD_CC="${CC:-gcc-16}"
BUILD_CXX="${CXX:-g++-16}"
command -v "$BUILD_CC" >/dev/null 2>&1 || die "validated compiler '$BUILD_CC' is unavailable; install GCC 16 or set CC to a compatible GCC 16 binary"
command -v "$BUILD_CXX" >/dev/null 2>&1 || die "validated compiler '$BUILD_CXX' is unavailable; install G++ 16 or set CXX to a compatible G++ 16 binary"
if ! compiler_version="$("$BUILD_CXX" -dumpfullversion -dumpversion 2>/dev/null)"; then
    die "cannot determine the version of validated compiler '$BUILD_CXX'"
fi
[[ "${compiler_version%%.*}" == 16 ]] || die "validated build requires GCC/G++ 16; '$BUILD_CXX' reports $compiler_version"
readonly BUILD_CC BUILD_CXX

for package_name in xdg-desktop-portal-hyprland libhyprcursor0; do
    if ! dpkg-query -W -f='${db:Status-Status}' "$package_name" 2>/dev/null | grep -qx installed; then
        die "required runtime package '$package_name' is not installed; install it separately, then rerun (this script only marks these packages manual)"
    fi
done

[[ -d /opt && -w /opt ]] || [[ -d /opt && "$EUID" -eq 0 ]] || die '/opt is unavailable for a root-owned installation'
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
    if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
        log "would move $PREFIX to a unique ${PREFIX}.rollback.* path"
    else
        log "would build pinned Hyprland $VERSION and install it at $PREFIX"
    fi
    log "would atomically publish $PUBLIC_BIN_DIR/{Hyprland,start-hyprland,hyprctl}"
    log "would recreate $PORTAL_FILE and mark only xdg-desktop-portal-hyprland and libhyprcursor0 manual"
    exit 0
fi

# Create all build files as SUDO_USER, never as root. In particular, do not
# copy or link the existing ~/.local/opt build: its RUNPATH points at that
# user-local prefix and cannot be promoted safely.
run_as_user() {
    runuser -u "$BUILD_USER" -- env HOME="$BUILD_HOME" USER="$BUILD_USER" LOGNAME="$BUILD_USER" CC="$BUILD_CC" CXX="$BUILD_CXX" "$@"
}
# Public sources must stay anonymous HTTPS even when the invoking user has a
# global or system Git URL rewrite (for example, HTTPS GitHub URLs to SSH).
# These environment overrides are scoped to this script's Git processes.
run_git_as_user() {
    run_as_user env \
        GIT_CONFIG_GLOBAL=/dev/null \
        GIT_CONFIG_NOSYSTEM=1 \
        GIT_TERMINAL_PROMPT=0 \
        git "$@"
}

run_as_user mkdir -p "$BUILD_HOME/.cache"
WORKSPACE="$(run_as_user mktemp -d "$BUILD_HOME/.cache/hyprland-systemwide.XXXXXX")"
[[ -n "$WORKSPACE" && -d "$WORKSPACE" ]] || die 'could not create the user-owned temporary build workspace'
[[ "$(stat -c '%u' "$WORKSPACE")" == "$(id -u "$BUILD_USER")" ]] || die 'temporary build workspace is not owned by SUDO_USER'
readonly WORKSPACE
STAGE="$WORKSPACE/stage"
BUILD_PREFIX="$WORKSPACE/prefix"
STAGED_PREFIX="$STAGE$PREFIX"
readonly STAGE BUILD_PREFIX STAGED_PREFIX
run_as_user mkdir -p "$WORKSPACE/src" "$WORKSPACE/build" "$BUILD_PREFIX" "$STAGED_PREFIX"

clone_pinned() {
    local name=$1 url=$2 commit=$3 destination="$WORKSPACE/src/$1" actual
    log "fetching pinned $name ($commit)"
    if ! run_git_as_user clone --filter=blob:none --no-tags "$url" "$destination"; then
        die "unable to fetch $name from $url; check network/DNS/firewall access and retry"
    fi
    if [[ "${#commit}" -eq 40 ]]; then
        if ! run_git_as_user -C "$destination" fetch --no-tags --depth=1 origin "$commit"; then
            die "fetched $name, but commit $commit is unavailable; verify source availability and provenance"
        fi
    else
        # The validated Glaze provenance records the unambiguous short ID
        # b518eec; fetch all refs so a server need not accept an abbreviated want.
        run_git_as_user -C "$destination" fetch --no-tags origin || die "fetched $name, but its pinned history is unavailable"
    fi
    run_git_as_user -C "$destination" checkout --detach --quiet "$commit" || die "cannot check out pinned $name commit $commit"
    actual="$(run_git_as_user -C "$destination" rev-parse HEAD)"
    [[ "$actual" == "$commit" || "$actual" == "$commit"* ]] || die "provenance mismatch for $name: expected $commit, got $actual"
}

# Exact revisions used by the validated v0.56.2 build. glaze is consumed by
# Hyprland's CMake FetchContent and is supplied from this pinned checkout.
clone_pinned hyprland https://github.com/hyprwm/Hyprland.git "$HYPRLAND_COMMIT"
clone_pinned aquamarine https://github.com/hyprwm/aquamarine.git 1a10fe26a9f7d989c359e6a9ea61aa2e44d06c36
clone_pinned hyprutils https://github.com/hyprwm/hyprutils.git 5a7b8cf221914ce4714407950e4ffbdddcd8b66f
clone_pinned hyprlang https://github.com/hyprwm/hyprlang.git 090117506ddc3d7f26e650ff344d378c2ec329cc
clone_pinned hyprcursor https://github.com/hyprwm/hyprcursor.git 39435900785d0c560c6ae8777d29f28617d031ef
clone_pinned hyprgraphics https://github.com/hyprwm/hyprgraphics.git 8699c38f0e4a1ca3bfc84f84ba020509ced1f133
clone_pinned hyprwayland-scanner https://github.com/hyprwm/hyprwayland-scanner.git b8632713a6beaf28b56f2a7b0ab2fb7088dbb404
clone_pinned hyprwire https://github.com/hyprwm/hyprwire.git 7d935bb54674aa0fbd327d2a6888bd0630079ed0
clone_pinned wayland https://gitlab.freedesktop.org/wayland/wayland.git 3e673a438b0a9749e3bdf5cac4befac86333024c
clone_pinned wayland-protocols https://gitlab.freedesktop.org/wayland/wayland-protocols.git ee78491a237eaff9389a0ccf8680521d074407d3
clone_pinned glaze https://github.com/stephenberry/glaze.git b518eec

readonly CMAKE_COMMON_ARGS=(
    -G Ninja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_PREFIX_PATH="$BUILD_PREFIX"
    -DCMAKE_C_COMPILER="$BUILD_CC"
    -DCMAKE_CXX_COMPILER="$BUILD_CXX"
    # Keep build/test binaries runnable from the private dependency prefix.
    # cmake --install replaces this with the final runtime prefix below.
    -DCMAKE_INSTALL_RPATH="$PREFIX/lib"
    -DCMAKE_BUILD_RPATH="$BUILD_PREFIX/lib"
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON
)

build_cmake() {
    local install_prefix=$1 name=$2 source=$3 build_dir="$WORKSPACE/build/$2"
    shift 3
    log "configuring $name"
    if ! run_as_user cmake -S "$source" -B "$build_dir" "${CMAKE_COMMON_ARGS[@]}" \
        -DCMAKE_INSTALL_PREFIX="$install_prefix" "$@"; then
        die "CMake configuration failed for $name; install its development dependencies and inspect the output"
    fi
    if ! run_as_user cmake --build "$build_dir" --parallel "${JOBS:-$(nproc)}"; then
        die "compilation failed for $name; verify the pinned toolchain and development headers"
    fi
    run_as_user cmake --install "$build_dir" || die "installation into the temporary prefix failed for $name"
}

build_meson() {
    local name=$1 source=$2 build_dir="$WORKSPACE/build/$1"
    shift 2
    log "configuring $name"
    if ! run_as_user meson setup "$build_dir" "$source" --prefix "$BUILD_PREFIX" --libdir lib --buildtype release --wrap-mode nodownload "${MESON_COMMON_ARGS[@]}" "$@"; then
        die "Meson configuration failed for $name; install its development dependencies and inspect the output"
    fi
    if ! run_as_user meson compile -C "$build_dir" -j "${JOBS:-$(nproc)}"; then
        die "compilation failed for $name; verify the pinned toolchain and development headers"
    fi
    run_as_user meson install -C "$build_dir" || die "installation into the temporary prefix failed for $name"
}

readonly MESON_COMMON_ARGS=(
    -Dc_link_args=-Wl,-rpath,"$BUILD_PREFIX/lib"
    -Dcpp_link_args=-Wl,-rpath,"$BUILD_PREFIX/lib"
    -Dbuild.rpath="$BUILD_PREFIX/lib"
)


build_cmake "$BUILD_PREFIX" hyprwayland-scanner "$WORKSPACE/src/hyprwayland-scanner"
build_cmake "$BUILD_PREFIX" hyprutils "$WORKSPACE/src/hyprutils"
build_cmake "$BUILD_PREFIX" hyprlang "$WORKSPACE/src/hyprlang"
build_cmake "$BUILD_PREFIX" hyprcursor "$WORKSPACE/src/hyprcursor"
build_cmake "$BUILD_PREFIX" hyprgraphics "$WORKSPACE/src/hyprgraphics"
build_cmake "$BUILD_PREFIX" hyprwire "$WORKSPACE/src/hyprwire"
build_meson wayland "$WORKSPACE/src/wayland" -Ddocumentation=false -Dtests=false
build_meson wayland-protocols "$WORKSPACE/src/wayland-protocols" -Dtests=false
build_cmake "$BUILD_PREFIX" aquamarine "$WORKSPACE/src/aquamarine"
build_cmake "$STAGED_PREFIX" hyprland "$WORKSPACE/src/hyprland" \
    -DNO_HYPRPM=ON -DNO_UWSM=ON -DNO_SYSTEMD=OFF -DNO_XWAYLAND=OFF \
    -DFETCHCONTENT_SOURCE_DIR_GLAZE="$WORKSPACE/src/glaze"

run_as_user cp -a -- "$BUILD_PREFIX/." "$STAGED_PREFIX/" || die 'could not copy the private dependency prefix into the staged versioned prefix'
[[ -x "$STAGED_PREFIX/bin/Hyprland" && -x "$STAGED_PREFIX/bin/start-hyprland" && -x "$STAGED_PREFIX/bin/hyprctl" ]] || die 'build completed without all three expected public binaries'

# Static audit before touching /opt. A build path in RUNPATH is unsafe even if
# the file happens to work on the build user's machine.
while IFS= read -r -d '' artifact; do
    if file -b "$artifact" | grep -q 'ELF'; then
        dynamic_info="$(readelf -d "$artifact" 2>/dev/null || true)"
        if grep -Fq "$BUILD_HOME/.local/opt" <<<"$dynamic_info" || grep -Fq "$BUILD_PREFIX" <<<"$dynamic_info"; then
            die "unsafe user-local/build-prefix RUNPATH in $artifact"
        fi
        if grep -q 'RUNPATH' <<<"$dynamic_info" && ! grep -Fq "$PREFIX/lib" <<<"$dynamic_info"; then
            die "installed ELF $artifact lacks the prefix-local RUNPATH $PREFIX/lib"
        fi
    fi
done < <(find "$STAGED_PREFIX" -type f -print0)

# A pre-existing prefix is moved, never deleted. This keeps every previous
# rollback copy intact and allows an interrupted replacement to be recovered.
rollback_prefix=''
if ! final_staging="$(mktemp -d "/opt/.hyprland-${VERSION}.install.XXXXXX")"; then
    die 'cannot create an isolated root staging directory under /opt'
fi
FINAL_STAGING="$final_staging"
if ! cp -a -- "$STAGED_PREFIX/." "$final_staging/"; then
    die "cannot copy the staged prefix into /opt; check free space and permissions"
fi
chown -R root:root "$final_staging"
if [[ -e "$PREFIX" || -L "$PREFIX" ]]; then
    rollback_prefix="$PREFIX.rollback.$ROLLBACK_TAG"
    while [[ -e "$rollback_prefix" || -L "$rollback_prefix" ]]; do
        rollback_prefix="$PREFIX.rollback.$ROLLBACK_TAG.$RANDOM"
    done
    mv -- "$PREFIX" "$rollback_prefix" || die "cannot preserve existing $PREFIX at $rollback_prefix"
    log "preserved previous prefix as $rollback_prefix"
fi
if ! mv -- "$final_staging" "$PREFIX"; then
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
restore_old_prefix() {
    if [[ -n "$rollback_prefix" && ( -e "$rollback_prefix" || -L "$rollback_prefix" ) ]]; then
        local failed="$PREFIX.failed.$ROLLBACK_TAG"
        mv -- "$PREFIX" "$failed" 2>/dev/null || true
        mv -- "$rollback_prefix" "$PREFIX" 2>/dev/null || true
        warn "new prefix failed validation and was retained as $failed; restored $PREFIX"
    fi
}

# Verify the real installed closure, not merely the staged files. RUNPATH must
# select /opt and ldd must not mention the old user-local build or not-found
# entries. Keep this before publishing any stable command names.
if ! installed_dynamic_info="$(readelf -d "$PREFIX/bin/Hyprland" 2>&1)"; then
    restore_old_prefix
    die 'cannot inspect the installed Hyprland ELF'
fi
if ! grep -Fq "RUNPATH" <<<"$installed_dynamic_info" || ! grep -Fq "$PREFIX/lib" <<<"$installed_dynamic_info"; then
    restore_old_prefix
    die "Hyprland RUNPATH does not point at $PREFIX/lib"
fi
for public_binary in Hyprland start-hyprland hyprctl; do
    closure="$(ldd "$PREFIX/bin/$public_binary" 2>&1 || true)"
    if grep -q 'not found' <<<"$closure" || grep -Fq "$BUILD_HOME/.local/opt" <<<"$closure" || grep -Fq "$BUILD_PREFIX" <<<"$closure"; then
        restore_old_prefix
        die "dependency closure for $public_binary is incomplete or points at the user-local build"
    fi
    coupled="$(grep -E 'lib(hypr|aquamarine|wayland|lua)' <<<"$closure" || true)"
    if [[ -n "$coupled" ]] && grep -qvF "$PREFIX/lib" <<<"$coupled"; then
        restore_old_prefix
        die "dependency closure for $public_binary does not resolve coupled libraries from $PREFIX/lib"
    fi
done
for public_binary in Hyprland hyprctl; do
    public_dynamic_info="$(readelf -d "$PREFIX/bin/$public_binary" 2>&1 || true)"
    if ! grep -Fq 'RUNPATH' <<<"$public_dynamic_info" || ! grep -Fq "$PREFIX/lib" <<<"$public_dynamic_info"; then
        restore_old_prefix
        die "$public_binary does not carry the required prefix-local RUNPATH $PREFIX/lib"
    fi
done
if ! version_output="$("$PREFIX/bin/Hyprland" --version 2>&1)" || ! grep -Eq "Hyprland[[:space:]]+$VERSION([[:space:]]|$)" <<<"$version_output"; then
    restore_old_prefix
    die "installed Hyprland did not report version $VERSION: $version_output"
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
cat >"$portal_temp" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.FileChooser=gtk
org.freedesktop.impl.portal.Print=gtk
org.freedesktop.impl.portal.AppChooser=gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
org.freedesktop.impl.portal.GlobalShortcuts=hyprland
EOF
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

log "Hyprland $VERSION ($HYPRLAND_COMMIT) installed at $PREFIX"
log 'public symlinks, portal preference, and minimal apt protection are ready'
