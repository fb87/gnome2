# AGENTS.md

## Project Goal

Build and restore a GNOME 2.32 desktop environment from the official GNOME 2.32.0 source release:

https://download.gnome.org/desktop/2.32/2.32.0/sources/

This project targets a reproducible Nix-based build, not direct installation into the host system.

## Build Strategy

Start with a minimal runnable `gnome2-core` desktop session before attempting the full GNOME 2.32 application set.

Core target components include:

- GConf
- ORBit2
- libbonobo
- libgnome
- libgnomeui
- gnome-menus
- gnome-desktop
- gnome-session
- gnome-panel
- metacity
- nautilus
- gnome-settings-daemon
- gnome-control-center
- gnome-icon-theme
- gnome-themes
- libwnck
- vte
- gnome-terminal

Defer optional applications such as Evolution, Epiphany, Totem, Brasero, Cheese, games, accessibility tools, and Mono applications until the core session starts reliably.

## Source Policy

Use the official GNOME 2.32.0 source tarballs, preferably `.tar.bz2` archives.

Use fixed-output hashes from:

https://download.gnome.org/desktop/2.32/2.32.0/sources/SHA256SUMS-for-bz2

Avoid vendoring source tarballs into the repository unless explicitly requested.

## Nix Policy

Use the flake as the entry point.

Prefer modern nixpkgs packages for still-supported foundational dependencies such as GTK 2, GLib, Pango, Cairo, D-Bus, gettext, pkg-config, libxml2, and intltool.

Restore removed GNOME 2 platform packages locally in this flake when current nixpkgs no longer provides working derivations.

Old nixpkgs expressions may be used as references, but should be adapted carefully instead of copied blindly.

## Editing Guidelines

Make the smallest correct change.

Preserve unrelated user changes in the working tree.

Do not revert, overwrite, or clean uncommitted changes unless explicitly asked.

Keep package definitions focused and incremental.

Avoid broad compatibility layers unless there is a concrete build or runtime need.

## Verification

For individual packages:

```sh
nix build .#<package>
```

For the core desktop bundle:

```sh
nix build .#gnome2-core
```

For general flake validation:

```sh
nix flake check
```

Runtime testing should initially use a nested X session such as Xephyr before adding any host desktop-session integration.

## Known Risk Areas

Expect issues from modern toolchains and removed legacy dependencies, including:

- GCC stricter diagnostics
- old GLib and GTK 2 assumptions
- Python 2-era build scripts
- obsolete intltool behavior
- missing transitive link flags
- removed GNOME 2 libraries in current nixpkgs
- GConf, D-Bus, session startup, and desktop service integration
