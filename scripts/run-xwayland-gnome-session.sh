#!/usr/bin/env bash
# Start the GNOME 2 session on the XWayland display provided by Niri's
# xwayland-satellite.
#
# Run this from a shell with Niri's WAYLAND_DISPLAY and XDG_RUNTIME_DIR set.

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GNOME2_CORE="${GNOME2_CORE:-$(nix build "$FLAKE_DIR#gnome2-core" --no-link --print-out-paths)}"
export GNOME2_CORE
DISPLAY_NUM="${DISPLAY:-:0}"
DISPLAY_SOCKET="/tmp/.X11-unix/X${DISPLAY_NUM#:}"
SATELLITE_PID=""

cleanup() {
  if [ -n "$SATELLITE_PID" ]; then
    kill "$SATELLITE_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if [ -z "${WAYLAND_DISPLAY:-}" ] || [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  echo "WAYLAND_DISPLAY and XDG_RUNTIME_DIR must come from the Niri session" >&2
  exit 1
fi

export XDG_DATA_DIRS="$GNOME2_CORE/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="$GNOME2_CORE/etc/xdg:${XDG_CONFIG_DIRS:-/etc/xdg}"
export PATH="$GNOME2_CORE/bin:$PATH"
export GTK_PATH="$GNOME2_CORE/lib/gtk-2.0"
export XCURSOR_PATH="$GNOME2_CORE/share/icons"
export XCURSOR_THEME="whiteglass"
export DISPLAY="$DISPLAY_NUM"
printf '%s\n' "xml:readonly:$GNOME2_CORE/etc/gconf/gconf.xml.defaults" > "$HOME/.gconf.path"

if ! [ -S "$DISPLAY_SOCKET" ]; then
  echo "==> starting xwayland-satellite on $DISPLAY_NUM" >&2
  nix shell nixpkgs#xwayland-satellite -c xwayland-satellite &
  SATELLITE_PID=$!
  for _ in $(seq 1 40); do
    [ -S "$DISPLAY_SOCKET" ] && break
    sleep 0.25
  done
fi

[ -S "$DISPLAY_SOCKET" ] || {
  echo "xwayland-satellite did not create $DISPLAY_SOCKET" >&2
  exit 1
}

exec dbus-run-session -- sh -c '
  gconftool-2 --load "$GNOME2_CORE/etc/gconf/schemas/panel-default-setup.entries"
  gconftool-2 --set --type=bool /apps/metacity/general/compositing_manager true
  exec gnome-session
'
