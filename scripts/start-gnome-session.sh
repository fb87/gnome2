#!/usr/bin/env bash
# Build (if needed) and run the gnome2-core session on a REAL X server via
# startx, instead of nested inside Xephyr like run-nested-session.sh. This
# grabs a real virtual terminal, so it's meant to be run from a text
# console (switch away from any existing graphical session first), not
# from inside another desktop session.
#
# It bootstraps the same GConf/D-Bus/theme state run-nested-session.sh
# does; see that script's header comment for why each piece is there.
#
# Usage: scripts/start-gnome-session.sh [display-number]
#   e.g. scripts/start-gnome-session.sh :1
#
# Env overrides:
#   GNOME2_CORE          path to a pre-built gnome2-core (skips nix build)
#   GNOME2_SESSION_HOME  HOME dir for the session (default: fresh temp dir)

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISPLAY_NUM="${1:-:1}"

GNOME2_CORE="${GNOME2_CORE:-}"
if [ -z "$GNOME2_CORE" ]; then
  echo "==> building gnome2-core" >&2
  GNOME2_CORE="$(nix build "$FLAKE_DIR#gnome2-core" --no-link --print-out-paths)"
fi

SESSION_HOME="${GNOME2_SESSION_HOME:-$(mktemp -d /tmp/gnome2-session.XXXXXX)}"
mkdir -p "$SESSION_HOME"

echo "==> session HOME: $SESSION_HOME" >&2
echo "==> gnome2-core: $GNOME2_CORE" >&2
echo "==> starting a real X server on $DISPLAY_NUM via startx" >&2

# startx's client argument is exec'd directly (no shell involved), so this
# has to be a real script rather than an inline command string.
CLIENT_SCRIPT="$SESSION_HOME/.gnome2-xclient.sh"
cat > "$CLIENT_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail
export HOME="$SESSION_HOME"
ln -sfn "$GNOME2_CORE/share/themes" "\$HOME/.themes"
ln -sfn "$GNOME2_CORE/share/icons" "\$HOME/.icons"
export XDG_DATA_HOME="\$HOME/.local/share"
export XDG_CONFIG_HOME="\$HOME/.config"
export XDG_DATA_DIRS="$GNOME2_CORE/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="$GNOME2_CORE/etc/xdg:\${XDG_CONFIG_DIRS:-/etc/xdg}"
export PATH="$GNOME2_CORE/bin:\$PATH"
export GTK_PATH="$GNOME2_CORE/lib/gtk-2.0"
export XCURSOR_PATH="$GNOME2_CORE/share/icons"
export XCURSOR_THEME="whiteglass"
mkdir -p "\$XDG_DATA_HOME" "\$XDG_CONFIG_HOME"

eval "\$(dbus-launch --sh-syntax)"

GCT="$GNOME2_CORE/bin/gconftool-2"
for f in "$GNOME2_CORE"/etc/gconf/schemas/*.schemas; do
  "\$GCT" --install-schema-file="\$f" >/dev/null
done
"\$GCT" --load "$GNOME2_CORE/etc/gconf/schemas/panel-default-setup.entries"
"\$GCT" --set --type=string /desktop/gnome/background/picture_filename \\
  "$GNOME2_CORE/share/pixmaps/backgrounds/gnome/nature/Aqua.jpg"
"\$GCT" --set --type=string /desktop/gnome/background/picture_options "zoom"
"\$GCT" --set --type=string /desktop/gnome/peripherals/mouse/cursor_theme "whiteglass"

exec "$GNOME2_CORE/bin/gnome-session"
EOF
chmod +x "$CLIENT_SCRIPT"

exec nix shell nixpkgs#xinit nixpkgs#xorg-server -c \
  startx "$CLIENT_SCRIPT" -- "$DISPLAY_NUM"
