# Building Hyprland 0.56.2 locally

The Ubuntu Resolute packages are sufficient for many generic build dependencies,
but its `libhyprutils-dev` 0.11.0 and `libhyprgraphics-dev` 0.5.0 are older than
the minimums required by Hyprland 0.56.2.

`scripts/build-hyprland-local.sh` therefore builds the Hypr ecosystem revisions
pinned by Hyprland 0.56.2's `flake.lock` into a temporary private prefix:

- hyprutils `5a7b8cf221914ce4714407950e4ffbdddcd8b66f`
- hyprwayland-scanner `b8632713a6beaf28b56f2a7b0ab2fb7088dbb404`
- hyprlang `090117506ddc3d7f26e650ff344d378c2ec329cc`
- hyprcursor `39435900785d0c560c6ae8777d29f28617d031ef`
- hyprgraphics `8699c38f0e4a1ca3bfc84f84ba020509ced1f133`
- aquamarine `1a10fe26a9f7d989c359e6a9ea61aa2e44d06c36`
- Hyprland `efb50993780079460b0cbed1363e2166a2de1d9f`

The script scopes `PATH`, `PKG_CONFIG_PATH`, `CMAKE_PREFIX_PATH`, and
`LD_LIBRARY_PATH` to the private prefix, so distro Hypr libraries do not win
during compilation. It does not write to `/usr/local` or `/opt`.

`wayland-protocols >= 1.49` must already be visible through pkg-config.
Generic development dependencies such as libinput, libseat, DRM, GBM,
libdisplay-info, libzip, librsvg, pugixml, cairo, and pango remain host-provided.
If one is missing, the CMake error identifies the package to install.

Run:

```bash
scripts/build-hyprland-local.sh --clean
```

After validation the completed prefix becomes:

```text
~/.local/opt/hyprland-0.56.2
```

Then promote it:

```bash
sudo scripts/install-hyprland-systemwide.sh --dry-run
sudo scripts/install-hyprland-systemwide.sh --yes

command -v hyprpm
hyprpm --help
```
