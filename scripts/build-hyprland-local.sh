#!/usr/bin/env bash
set -Eeuo pipefail

readonly VERSION='0.56.2'
readonly FINAL_PREFIX="$HOME/.local/opt/hyprland-${VERSION}"
readonly CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-build"

readonly HYPRLAND_COMMIT='efb50993780079460b0cbed1363e2166a2de1d9f'
readonly HYPRUTILS_COMMIT='5a7b8cf221914ce4714407950e4ffbdddcd8b66f'
readonly SCANNER_COMMIT='b8632713a6beaf28b56f2a7b0ab2fb7088dbb404'
readonly HYPRLANG_COMMIT='090117506ddc3d7f26e650ff344d378c2ec329cc'
readonly HYPRCURSOR_COMMIT='39435900785d0c560c6ae8777d29f28617d031ef'
readonly HYPRGRAPHICS_COMMIT='8699c38f0e4a1ca3bfc84f84ba020509ced1f133'
readonly AQUAMARINE_COMMIT='1a10fe26a9f7d989c359e6a9ea61aa2e44d06c36'
readonly HYPRWIRE_COMMIT='7d935bb54674aa0fbd327d2a6888bd0630079ed0'

CLEAN=0
STAGE_PREFIX=''
BACKUP_PREFIX=''
PREPARED_SOURCE=''
PATCHED_HYPRLAND_SOURCE=''

log() { printf '[hyprland-build] %s\n' "$*"; }
die() { printf '[hyprland-build] error: %s\n' "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --clean) CLEAN=1 ;;
        --help|-h)
            printf '%s\n' \
                'Usage: scripts/build-hyprland-local.sh [--clean]' \
                "Build Hyprland $VERSION plus its pinned Hypr libraries." \
                "Output: $FINAL_PREFIX"
            exit 0
            ;;
        *) die "unknown option '$1'" ;;
    esac
    shift
done

[[ "$EUID" -ne 0 ]] || die 'run as your normal user, not with sudo'

export CC="${CC:-gcc-16}"
export CXX="${CXX:-g++-16}"

for cmd in git cmake pkg-config python3 cp mv rm mkdir grep ldd nproc mktemp date dpkg "$CC" "$CXX"; do
    command -v "$cmd" >/dev/null || die "required command '$cmd' is unavailable"
done

wp_version="$(pkg-config --modversion wayland-protocols 2>/dev/null || true)"
[[ -n "$wp_version" ]] || die 'wayland-protocols is not visible to pkg-config'
dpkg --compare-versions "$wp_version" ge 1.49 \
    || die "wayland-protocols >= 1.49 is required; found $wp_version"

mkdir -p "$CACHE_ROOT" "${FINAL_PREFIX%/*}"
STAGE_PREFIX="$(mktemp -d "${FINAL_PREFIX%/*}/.hyprland-${VERSION}.stage.XXXXXX")"

cleanup() {
    local status=$?
    if [[ -n "$PATCHED_HYPRLAND_SOURCE" && -d "$PATCHED_HYPRLAND_SOURCE/.git" ]]; then
        git -C "$PATCHED_HYPRLAND_SOURCE" checkout -- hyprpm/src/core/PluginManager.cpp >/dev/null 2>&1 || true
    fi
    [[ -z "$STAGE_PREFIX" || ! -d "$STAGE_PREFIX" ]] || rm -rf -- "$STAGE_PREFIX"
    return "$status"
}
trap cleanup EXIT

export PATH="$STAGE_PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$STAGE_PREFIX/lib/pkgconfig:$STAGE_PREFIX/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export CMAKE_PREFIX_PATH="$STAGE_PREFIX${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
export LD_LIBRARY_PATH="$STAGE_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

prepare_source() {
    local name=$1 url=$2 commit=$3
    local dir="$CACHE_ROOT/$name"

    if [[ ! -d "$dir/.git" ]]; then
        [[ ! -e "$dir" ]] || die "source path exists without .git: $dir"
        log "cloning $name"
        git clone "$url" "$dir"
    else
        [[ -z "$(git -C "$dir" status --porcelain --untracked-files=no)" ]] \
            || die "tracked changes found in $dir"
        log "refreshing $name"
        git -C "$dir" fetch --force origin "$commit"
    fi

    git -C "$dir" checkout --detach "$commit"
    PREPARED_SOURCE="$dir"
}

patch_hyprpm_workdir_ownership() {
    local source=$1
    python3 - "$source/hyprpm/src/core/PluginManager.cpp" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = r'''
    cmd = std::format("make -C '{}' installheaders && chmod -R 644 '{}' && find '{}' -type d -exec chmod a+x {{}} \\;", WORKINGDIR, DataState::getHeadersPath(),
                      DataState::getHeadersPath());
'''
new = r'''
    cmd = std::format(
        "make -C '{}' installheaders && chmod -R 644 '{}' && find '{}' -type d -exec chmod a+x {{}} \\; ; status=$?; chown -R {}:{} '{}'; exit $status",
        WORKINGDIR, DataState::getHeadersPath(), DataState::getHeadersPath(), getuid(), getgid(), WORKINGDIR);
'''
if old not in text:
    raise SystemExit(f"expected hyprpm v0.56.2 installheaders block not found in {path}")
path.write_text(text.replace(old, new, 1))
PY
    PATCHED_HYPRLAND_SOURCE="$source"
}

relocate_prefix_metadata() {
    local from=$1 to=$2
    python3 - "$from" "$to" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1])
target = sys.argv[2]
roots = (
    source / "lib/pkgconfig",
    source / "share/pkgconfig",
    source / "lib/cmake",
    source / "share/cmake",
)

for root in roots:
    if not root.is_dir():
        continue
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix not in {".pc", ".cmake"}:
            continue
        text = path.read_text()
        updated = text.replace(str(source), target)
        if updated != text:
            path.write_text(updated)

for root in roots:
    if not root.is_dir():
        continue
    for path in root.rglob("*"):
        if path.is_file() and path.suffix in {".pc", ".cmake"} and str(source) in path.read_text():
            raise SystemExit(f"unrelocated staging prefix remains in {path}")
PY
}

build_project() {
    local name=$1 url=$2 commit=$3
    shift 3

    prepare_source "$name" "$url" "$commit"
    local src="$PREPARED_SOURCE"
    local build="$src/build-local"

    [[ "$CLEAN" -eq 0 ]] || rm -rf -- "$build"

    log "configuring $name"
    cmake --no-warn-unused-cli \
        -S "$src" -B "$build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$STAGE_PREFIX" \
        "$@"

    log "building $name"
    cmake --build "$build" --config Release --parallel "$(nproc)"

    log "installing $name into private prefix"
    cmake --install "$build" --config Release
}

build_project hyprutils \
    https://github.com/hyprwm/hyprutils.git "$HYPRUTILS_COMMIT"

build_project hyprwire \
    https://github.com/hyprwm/hyprwire.git \
    "$HYPRWIRE_COMMIT"

build_project hyprwayland-scanner \
    https://github.com/hyprwm/hyprwayland-scanner.git "$SCANNER_COMMIT"

build_project hyprlang \
    https://github.com/hyprwm/hyprlang.git "$HYPRLANG_COMMIT"

build_project hyprcursor \
    https://github.com/hyprwm/hyprcursor.git "$HYPRCURSOR_COMMIT"

build_project hyprgraphics \
    https://github.com/hyprwm/hyprgraphics.git "$HYPRGRAPHICS_COMMIT"

build_project aquamarine \
    https://github.com/hyprwm/aquamarine.git "$AQUAMARINE_COMMIT"

prepare_source "Hyprland-${VERSION}" \
    https://github.com/hyprwm/Hyprland.git "$HYPRLAND_COMMIT"
HYPRLAND_SOURCE="$PREPARED_SOURCE"
git -C "$HYPRLAND_SOURCE" submodule sync --recursive
git -C "$HYPRLAND_SOURCE" submodule update --init --recursive
patch_hyprpm_workdir_ownership "$HYPRLAND_SOURCE"

HYPRLAND_BUILD="$HYPRLAND_SOURCE/build-local"
[[ "$CLEAN" -eq 0 ]] || rm -rf -- "$HYPRLAND_BUILD"

log "configuring Hyprland $VERSION with hyprpm enabled"
cmake --no-warn-unused-cli \
    -S "$HYPRLAND_SOURCE" -B "$HYPRLAND_BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$STAGE_PREFIX" \
    -DNO_HYPRPM=OFF

log "building Hyprland $VERSION"
cmake --build "$HYPRLAND_BUILD" --config Release --parallel "$(nproc)"
cmake --install "$HYPRLAND_BUILD" --config Release

for bin in Hyprland start-hyprland hyprctl hyprpm; do
    [[ -x "$STAGE_PREFIX/bin/$bin" ]] || die "missing executable after build: $bin"
done

for req in \
    'hyprutils >= 0.14.0' \
    'hyprwire >= 0.3.1' \
    'hyprwayland-scanner >= 0.3.10' \
    'hyprgraphics >= 0.5.1' \
    'hyprlang >= 0.6.7' \
    'hyprcursor >= 0.1.7' \
    'aquamarine >= 0.9.3'
do
    pkg-config --exists "$req" || die "private dependency check failed: $req"
done

version="$("$STAGE_PREFIX/bin/Hyprland" --version 2>&1)" \
    || die 'Hyprland failed version validation'
grep -Eq "^Hyprland[[:space:]]+$VERSION([[:space:]]|$)" <<<"$version" \
    || die "unexpected Hyprland version: $version"

for bin in Hyprland hyprctl hyprpm; do
    closure="$(ldd "$STAGE_PREFIX/bin/$bin" 2>&1 || true)"
    if grep -q 'not found' <<<"$closure"; then
        printf '%s\n' "$closure" >&2
        die "unresolved shared library in $bin"
    fi
done

log "relocating pkg-config/CMake metadata to $FINAL_PREFIX"
relocate_prefix_metadata "$STAGE_PREFIX" "$FINAL_PREFIX"

if [[ -e "$FINAL_PREFIX" || -L "$FINAL_PREFIX" ]]; then
    BACKUP_PREFIX="${FINAL_PREFIX}.rollback.$(date -u +%Y%m%dT%H%M%SZ)"
    mv -- "$FINAL_PREFIX" "$BACKUP_PREFIX"
    log "preserved previous local prefix as $BACKUP_PREFIX"
fi

mv -- "$STAGE_PREFIX" "$FINAL_PREFIX"
STAGE_PREFIX=''

log "validated local prefix is ready: $FINAL_PREFIX"
log 'next: sudo scripts/install-hyprland-systemwide.sh --dry-run'
