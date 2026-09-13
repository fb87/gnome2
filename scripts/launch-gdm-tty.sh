#!/usr/bin/env bash
# Launch the gdm we built directly from a real tty: takes over a virtual
# terminal to show gdm's actual login greeter, does PAM auth, then starts
# gnome-session -- unlike the other two scripts, which skip login
# entirely and just start a session directly.
#
# This is a materially more invasive operation than the other two
# scripts: it needs root, a writable runtime state directory (gdm's
# PID/auth/working/cache paths are compiled-in constants -- see the gdm
# derivation's comment in pkgs/gnome2/default.nix), a "gdm" system user
# for the greeter to run as, and a real /etc/pam.d/gdm on the host (PAM
# is a system library; it always reads there, there's no per-app way to
# point it elsewhere). This script checks for all of that and tells you
# exactly what's missing rather than silently working around it -- the
# PAM file in particular it will only write if you explicitly opt in.
#
# Run this from an actual virtual console (switch away from any existing
# graphical session first -- Ctrl+Alt+F<n> on most setups), as root:
#   sudo scripts/launch-gdm-tty.sh
#
# Env overrides:
#   GNOME2_CORE               path to a pre-built gnome2-core (skips nix build)
#   GNOME2_GDM_STATE_DIR      real runtime state dir (default: /var/lib/gnome2-gdm)
#   GNOME2_GDM_INSTALL_PAM=1  write a minimal /etc/pam.d/gdm if it's missing
#                             (printed below either way so you can review it first)

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${GNOME2_GDM_STATE_DIR:-/var/lib/gnome2-gdm}"

if [ "$(id -u)" -ne 0 ]; then
  echo "This needs root (it manages a real VT, PAM auth, and system-wide" >&2
  echo "runtime directories). Try: sudo $0" >&2
  exit 1
fi

GNOME2_CORE="${GNOME2_CORE:-}"
if [ -z "$GNOME2_CORE" ]; then
  echo "==> building gnome2-core" >&2
  GNOME2_CORE="$(nix build "$FLAKE_DIR#gnome2-core" --no-link --print-out-paths)"
fi

echo "==> building gdm" >&2
GDM_OUT="$(nix build "$FLAKE_DIR#gdm" --no-link --print-out-paths)"

echo "==> gnome2-core: $GNOME2_CORE" >&2
echo "==> gdm: $GDM_OUT" >&2

# --- preflight checks ---------------------------------------------------

if ! id gdm >/dev/null 2>&1; then
  cat >&2 <<'EOF'

No "gdm" system user exists. gdm-binary is compiled with GDM_USERNAME
"gdm" (the upstream default) and drops the greeter process to that user
for privilege separation -- this script won't create system accounts on
its own. Create one first, e.g.:

  useradd --system --home-dir /var/lib/gnome2-gdm --shell /usr/sbin/nologin gdm

then re-run this script.
EOF
  exit 1
fi

PAM_STACK='#%PAM-1.0
auth       required     pam_unix.so
account    required     pam_unix.so
password   required     pam_unix.so
session    required     pam_unix.so
session    optional     pam_env.so'

PAM_SERVICE=/etc/pam.d/gdm
if [ ! -e "$PAM_SERVICE" ]; then
  if [ "${GNOME2_GDM_INSTALL_PAM:-0}" = "1" ]; then
    echo "==> writing a minimal $PAM_SERVICE (GNOME2_GDM_INSTALL_PAM=1)" >&2
    printf '%s\n' "$PAM_STACK" > "$PAM_SERVICE"
  else
    cat >&2 <<EOF

PAM is a system library: pam_start() always reads $PAM_SERVICE from the
real host filesystem, with no per-application override. That file
doesn't exist, so login would fail immediately. Either create it
yourself, or re-run with GNOME2_GDM_INSTALL_PAM=1 to have this script
write the minimal stack below:

$PAM_STACK
EOF
    exit 1
  fi
fi

# --- runtime state directory ---------------------------------------
# gdm-binary's PID/auth/working/screenshot/cache paths are compiled-in C
# string constants pointing under $STATE_DIR (a real host path chosen at
# build time -- see pkgs/gnome2/default.nix). Nothing here is optional;
# gdm will fail to write its X auth cookies without it.
mkdir -p /var/log/gdm /var/run
for sub in gdm lib/gdm run/gdm run/gdm/greeter cache/gdm; do
  mkdir -p "$STATE_DIR/$sub"
done
chown -R gdm:gdm "$STATE_DIR" /var/log/gdm 2>/dev/null || true

# --- session entry -------------------------------------------------
# The greeter's session list (gui/simple-greeter/gdm-sessions.c) scans a
# fixed set of directories; /etc/X11/sessions/ is the only one that's a
# plain hardcoded host path rather than something under gdm's own
# (read-only) compiled-in $out/share, so that's where the session
# .desktop file needs to live.
SESSION_WRAPPER="$STATE_DIR/gnome2-xsession"
cat > "$SESSION_WRAPPER" <<EOF
#!/usr/bin/env bash
set -euo pipefail
# Same theme/icon-scanner workaround as the other two session scripts
# (see run-nested-session.sh's header comment for why these two GTK+
# theme/icon discovery paths need it).
ln -sfn "$GNOME2_CORE/share/themes" "\$HOME/.themes"
ln -sfn "$GNOME2_CORE/share/icons" "\$HOME/.icons"
export XDG_DATA_DIRS="$GNOME2_CORE/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="$GNOME2_CORE/etc/xdg:\${XDG_CONFIG_DIRS:-/etc/xdg}"
export PATH="$GNOME2_CORE/bin:\$PATH"
export GTK_PATH="$GNOME2_CORE/lib/gtk-2.0"
export XCURSOR_PATH="$GNOME2_CORE/share/icons"
export XCURSOR_THEME="whiteglass"
exec "$GNOME2_CORE/bin/gnome-session"
EOF
chmod +x "$SESSION_WRAPPER"

mkdir -p /etc/X11/sessions
cat > /etc/X11/sessions/gnome2.desktop <<EOF
[Desktop Entry]
Name=GNOME 2 (Nix build)
Comment=Custom-built GNOME 2.32 desktop (gnome2 flake)
Exec=$SESSION_WRAPPER
Type=Application
EOF

echo "==> starting gdm in the foreground (Ctrl+C to stop)" >&2
exec "$GDM_OUT/bin/gdm-binary"
