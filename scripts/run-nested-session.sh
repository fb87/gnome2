#!/usr/bin/env bash
# Build (if needed) and run the gnome2-core session inside a nested Xephyr
# display, bootstrapping the D-Bus/GConf state that the Nix packaging can't
# set up at build time:
#
#   - GConf schema defaults are normally installed by package postinstall
#     scripts; ours skip that at build time (GCONF_SANITY_CHECK) since gconfd
#     can't be spawned inside the build sandbox, so it has to happen here.
#   - gnome-panel only copies its default layout out of
#     /apps/panel/default_setup on its very first run; that tree must be
#     loaded before gnome-session starts the panel, or you get one empty
#     auto-generated panel instead of the real top/bottom layout.
#   - metacity's schema default theme is "Clearlooks", which isn't packaged
#     (no gnome-themes derivation yet), so it's pinned to "Atlanta", a theme
#     metacity ships itself.
#
# Usage: scripts/run-nested-session.sh [gnome-session args...]
#
# Env overrides:
#   GNOME2_CORE          path to a pre-built gnome2-core (skips nix build)
#   GNOME2_SESSION_HOME  HOME dir for the session (default: fresh temp dir)
#   GNOME2_DISPLAY       nested display number (default: :10)
#   GNOME2_SCREEN_SIZE   Xephyr screen size (default: 1280x800)
#   GNOME2_HOST_DISPLAY  host display Xephyr nests inside (default: $DISPLAY, else :0)

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GNOME2_CORE="${GNOME2_CORE:-}"
if [ -z "$GNOME2_CORE" ]; then
  echo "==> building gnome2-core" >&2
  GNOME2_CORE="$(nix build "$FLAKE_DIR#gnome2-core" --no-link --print-out-paths)"
fi

SESSION_HOME="${GNOME2_SESSION_HOME:-$(mktemp -d /tmp/gnome2-session.XXXXXX)}"
DISPLAY_NUM="${GNOME2_DISPLAY:-:10}"
SCREEN_SIZE="${GNOME2_SCREEN_SIZE:-1280x800}"
HOST_DISPLAY="${GNOME2_HOST_DISPLAY:-${DISPLAY:-:0}}"

mkdir -p "$SESSION_HOME"
export HOME="$SESSION_HOME"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_DIRS="$GNOME2_CORE/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export PATH="$GNOME2_CORE/bin:$PATH"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"

echo "==> session HOME: $HOME" >&2
echo "==> gnome2-core: $GNOME2_CORE" >&2

cleanup_pids=()
cleanup() {
  for pid in "${cleanup_pids[@]}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT

display_is_up() {
  nix shell nixpkgs#xdpyinfo -c bash -c "DISPLAY=$DISPLAY_NUM xdpyinfo" >/dev/null 2>&1
}

if ! display_is_up; then
  echo "==> starting Xephyr on $DISPLAY_NUM (nested in host display $HOST_DISPLAY)" >&2
  DISPLAY="$HOST_DISPLAY" nix shell nixpkgs#xorg-server -c Xephyr "$DISPLAY_NUM" -screen "$SCREEN_SIZE" -resizeable &
  cleanup_pids+=("$!")
  for _ in $(seq 1 40); do
    display_is_up && break
    sleep 0.5
  done
  display_is_up || { echo "Xephyr failed to start on $DISPLAY_NUM" >&2; exit 1; }
fi
export DISPLAY="$DISPLAY_NUM"

# Must come after XDG_DATA_DIRS is set: the session bus reads it at spawn
# time to build its D-Bus service search path, which is how gconftool-2
# activates org.gnome.GConf later on.
eval "$(dbus-launch --sh-syntax)"
cleanup_pids+=("$DBUS_SESSION_BUS_PID")

GCT="$GNOME2_CORE/bin/gconftool-2"

echo "==> installing GConf schema defaults" >&2
for f in "$GNOME2_CORE"/etc/gconf/schemas/*.schemas; do
  "$GCT" --install-schema-file="$f" >/dev/null
done

"$GCT" --type string --set /apps/metacity/general/theme Atlanta

echo "==> loading default panel layout" >&2
"$GCT" --load "$GNOME2_CORE/etc/gconf/schemas/panel-default-setup.entries"

echo "==> starting gnome-session" >&2
"$GNOME2_CORE/bin/gnome-session" "$@"
