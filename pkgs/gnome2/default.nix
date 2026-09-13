{
  lib,
  stdenv,
  fetchurl,
  atk,
  atkmm,
  bison,
  buildEnv,
  bzip2,
  cairomm,
  coreutils,
  dbus,
  dbus-glib,
  desktop-file-utils,
  elfutils,
  flex,
  fontconfig,
  gettext,
  glib,
  glibmm,
  gmime,
  gnupg,
  gnutls,
  gpgme,
  openssh,
  gtk2,
  gnomeDocUtils,
  iconnamingutils,
  intltool,
  lcms1,
  libexif,
  libgcrypt,
  libjpeg,
  libgudev,
  linux-pam,
  libICE,
  libnotify,
  librsvg,
  libSM,
  libstartup_notification,
  libproxy,
  libtasn1,
  libtool,
  libvorbis,
  sqlite,
  ncurses,
  pango,
  pangomm,
  libx11,
  libxau,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libXi,
  libxklavier,
  libXScrnSaver,
  libXtst,
  libxrender,
  libxres,
  libxrandr,
  libxxf86vm,
  pkg-config,
  libxml2,
  libxslt,
  perlPackages,
  poppler,
  popt,
  sane-backends,
  python3,
  shared-mime-info,
  tzdata,
  upower,
  which,
  xcursor-themes,
  zenity,
  zlib,
}:

let
  sources = import ./sources.nix { inherit fetchurl; };

  # nixpkgs' own libcanberra in this snapshot only wires up a GTK3 module
  # (gtkSupport = "gtk3"); several GTK2 apps need the GTK2 module
  # (canberra-gtk.h / ca_gtk_context_get), so build it ourselves from the
  # upstream tarball with --enable-gtk (auto-detected against our gtk2).
  libcanberra = stdenv.mkDerivation rec {
    pname = "libcanberra";
    version = "0.30";

    src = sources.libcanberra;

    configureFlags = [
      "--disable-alsa"
      "--disable-oss"
      "--disable-pulse"
      "--disable-udev"
      "--disable-gstreamer"
      "--disable-gtk3"
      "--disable-tdb"
      "--disable-lynx"
    ];

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libtool
      libvorbis
      libx11
    ];

    meta = {
      description = "Implementation of the XDG Sound Theme and Name Specifications (GTK2 module)";
      homepage = "http://0pointer.de/lennart/projects/libcanberra/";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.linux;
    };
  };

  gdm = stdenv.mkDerivation rec {
    pname = "gdm";
    version = "2.32.0";

    src = sources.gdm;

    configureFlags = [
      "--disable-scrollkeeper"
      "--with-console-kit=no"
      "--with-at-spi-registryd-directory=${at-spi2-core}/libexec"
      # GDM_WORKING_DIR/GDM_XAUTH_DIR/GDM_SCREENSHOT_DIR/authdir/cachedir are
      # all derived from --localstatedir and compiled in as fixed C string
      # constants (no command-line override exists in gdm-binary itself --
      # confirmed against daemon/main.c's GOptionEntry list). Left at the
      # default, they'd point at $out/var/... : a read-only Nix store path,
      # so gdm would crash immediately trying to write its X auth cookies.
      # Configure against the real runtime location we want compiled in...
      "--localstatedir=/var/lib/gnome2-gdm"
      # GDM_USERNAME/GDM_GROUPNAME are likewise compiled-in constants (no
      # runtime override in gdm-binary) -- gdm normally drops the greeter
      # process to a dedicated unprivileged "gdm" user for privilege
      # separation, which means that account has to exist on the host
      # before gdm can run at all. Pointing this at "root" (which always
      # exists, on every system) removes that setup step entirely, at the
      # cost of the greeter running as root instead of a separate
      # unprivileged user -- an accepted trade-off for a personal/test
      # setup, not something to carry into a real multi-user deployment.
      "--with-user=root"
      "--with-group=root"
    ];

    # ...but redirect the actual `make install` file copies back into $out,
    # so the build sandbox never touches a real /var path. The launch
    # script creates the matching real directory at runtime. Most
    # localstatedir-derived paths are live `$(localstatedir)/...` Makefile
    # references (a plain recursive `=` assignment, so a command-line
    # override cascades correctly), but GDM_WORKING_DIR/GDM_XAUTH_DIR/
    # GDM_SCREENSHOT_DIR are pre-resolved into fixed strings by configure's
    # own AC_SUBST and baked into Makefile.in as already-expanded values --
    # overriding `localstatedir` alone doesn't touch those, so they need
    # their own explicit overrides.
    installFlags = [
      "localstatedir=${placeholder "out"}/var/lib/gnome2-gdm"
      "GDM_WORKING_DIR=${placeholder "out"}/var/lib/gnome2-gdm/lib/gdm"
      "GDM_XAUTH_DIR=${placeholder "out"}/var/lib/gnome2-gdm/run/gdm"
      "GDM_SCREENSHOT_DIR=${placeholder "out"}/var/lib/gnome2-gdm/run/gdm/greeter"
    ];

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      libxslt
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      ORBit2
      dbus-glib
      fontconfig
      glib
      gnome-panel
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libcanberra
      libgnome
      libgnomecanvas
      libx11
      libxau
      libxklavier
      linux-pam
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 display manager (login screen / session launcher)";
      homepage = "https://download.gnome.org/sources/gdm/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-backgrounds = stdenv.mkDerivation rec {
    pname = "gnome-backgrounds";
    version = "2.32.0";

    src = sources.gnome-backgrounds;

    nativeBuildInputs = [
      intltool
      pkg-config
    ];

    meta = {
      description = "GNOME 2 default desktop wallpapers";
      homepage = "https://download.gnome.org/sources/gnome-backgrounds/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-icon-theme-symbolic = stdenv.mkDerivation rec {
    pname = "gnome-icon-theme-symbolic";
    version = "2.31.0";

    src = sources.gnome-icon-theme-symbolic;

    nativeBuildInputs = [
      iconnamingutils
      intltool
      pkg-config
    ];

    meta = {
      description = "GNOME 2 monochrome/symbolic icon set";
      homepage = "https://download.gnome.org/sources/gnome-icon-theme-symbolic/";
      license = lib.licenses.lgpl3Plus;
      platforms = lib.platforms.linux;
    };
  };

  gtkEngines = stdenv.mkDerivation rec {
    pname = "gtk-engines";
    version = "2.20.1";

    src = sources.gtk-engines;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [ gtk2 ];

    meta = {
      description = "Theme engines for GTK 2, including Clearlooks";
      homepage = "https://download.gnome.org/sources/gtk-engines/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libIDL = stdenv.mkDerivation rec {
    pname = "libIDL";
    version = "0.8.14";

    src = sources.libIDL;

    nativeBuildInputs = [
      bison
      flex
      pkg-config
    ];

    buildInputs = [
      glib
    ];

    meta = {
      description = "IDL parsing library used by ORBit2";
      homepage = "https://download.gnome.org/sources/libIDL/";
      license = lib.licenses.lgpl2Only;
      platforms = lib.platforms.linux;
    };
  };

  ORBit2 = stdenv.mkDerivation rec {
    pname = "ORBit2";
    version = "2.14.19";

    src = sources.ORBit2;

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      glib
      libIDL
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "CORBA 2.4-compliant Object Request Broker for GNOME 2";
      homepage = "https://download.gnome.org/sources/ORBit2/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  GConf = stdenv.mkDerivation rec {
    pname = "GConf";
    version = "2.32.0";

    src = sources.GConf;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      ORBit2
      dbus-glib
      glib
      libxml2
    ];

    configureFlags = [
      "--disable-defaults-service"
      "--disable-gsettings-backend"
    ];

    meta = {
      description = "GNOME 2 configuration database system";
      homepage = "https://download.gnome.org/sources/GConf/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libbonobo = stdenv.mkDerivation rec {
    pname = "libbonobo";
    version = "2.32.0";

    src = sources.libbonobo;

    nativeBuildInputs = [
      bison
      flex
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      glib
      libxml2
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Bonobo component framework library for GNOME 2";
      homepage = "https://download.gnome.org/sources/libbonobo/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-mime-data = stdenv.mkDerivation rec {
    pname = "gnome-mime-data";
    version = "2.18.0";

    src = sources.gnome-mime-data;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    meta = {
      description = "GNOME 2 MIME and application database";
      homepage = "https://download.gnome.org/sources/gnome-mime-data/";
      license = lib.licenses.gpl2Only;
      platforms = lib.platforms.linux;
    };
  };

  gnome-vfs = stdenv.mkDerivation rec {
    pname = "gnome-vfs";
    version = "2.24.4";

    src = sources.gnome-vfs;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      bzip2
      dbus-glib
      gnome-mime-data
      glib
      libxml2
    ];

    configureFlags = [
      "--disable-avahi"
      "--disable-fam"
      "--disable-hal"
      "--disable-samba"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 virtual file system library";
      homepage = "https://download.gnome.org/sources/gnome-vfs/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnome = stdenv.mkDerivation rec {
    pname = "libgnome";
    version = "2.32.0";

    src = sources.libgnome;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      gnome-vfs
      glib
      libbonobo
      libcanberra
      libxml2
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Core GNOME 2 library";
      homepage = "https://download.gnome.org/sources/libgnome/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libart_lgpl = stdenv.mkDerivation rec {
    pname = "libart_lgpl";
    version = "2.3.21";

    src = sources.libart_lgpl;

    nativeBuildInputs = [ pkg-config ];

    meta = {
      description = "LGPL vector drawing library used by GNOME 2";
      homepage = "https://download.gnome.org/sources/libart_lgpl/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnomeprint = stdenv.mkDerivation rec {
    pname = "libgnomeprint";
    version = "2.18.8";

    src = sources.libgnomeprint;

    patches = [ ./patches/libgnomeprint-modern-bison.patch ];

    nativeBuildInputs = [
      bison
      flex
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      fontconfig
      glib
      libart_lgpl
      libxml2
      pango
    ];

    configureFlags = [
      "--without-cups"
      "--without-papi"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 printing support library";
      homepage = "https://download.gnome.org/sources/libgnomeprint/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnomecanvas = stdenv.mkDerivation rec {
    pname = "libgnomecanvas";
    version = "2.30.3";

    src = sources.libgnomecanvas;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libart_lgpl
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Canvas widget library for GNOME 2";
      homepage = "https://download.gnome.org/sources/libgnomecanvas/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnomeprintui = stdenv.mkDerivation rec {
    pname = "libgnomeprintui";
    version = "2.18.6";

    src = sources.libgnomeprintui;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      fontconfig
      gnome-icon-theme
      gtk2
      libart_lgpl
      libgnomecanvas
      libgnomeprint
      libxml2
      pango
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 printing UI library";
      homepage = "https://download.gnome.org/sources/libgnomeprintui/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libglade = stdenv.mkDerivation rec {
    pname = "libglade";
    version = "2.6.4";

    src = sources.libglade;

    nativeBuildInputs = [
      gettext
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Runtime library for loading GTK 2 Glade interfaces";
      homepage = "https://download.gnome.org/sources/libglade/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnome-keyring = stdenv.mkDerivation rec {
    pname = "libgnome-keyring";
    version = "2.32.0";

    src = sources.libgnome-keyring;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      dbus-glib
      glib
      libgcrypt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 keyring client library";
      homepage = "https://download.gnome.org/sources/libgnome-keyring/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libbonoboui = stdenv.mkDerivation rec {
    pname = "libbonoboui";
    version = "2.24.5";

    src = sources.libbonoboui;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      glib
      gtk2
      libart_lgpl
      libbonobo
      libglade
      libgnome
      libgnomecanvas
      libxml2
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Bonobo UI library for GNOME 2";
      homepage = "https://download.gnome.org/sources/libbonoboui/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnomeui = stdenv.mkDerivation rec {
    pname = "libgnomeui";
    version = "2.24.5";

    src = sources.libgnomeui;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      gnome-vfs
      ORBit2
      glib
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libglade
      libgnome
      libgnomecanvas
      libgnome-keyring
      libxml2
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 user interface library";
      homepage = "https://download.gnome.org/sources/libgnomeui/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-menus = stdenv.mkDerivation rec {
    pname = "gnome-menus";
    version = "2.30.4";

    src = sources.gnome-menus;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [ glib ];

    configureFlags = [ "--disable-python" ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 menu layout and desktop entry library";
      homepage = "https://download.gnome.org/sources/gnome-menus/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-desktop = stdenv.mkDerivation rec {
    pname = "gnome-desktop";
    version = "2.32.0";

    src = sources.gnome-desktop;

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
      python3
      which
    ];

    buildInputs = [
      GConf
      gnome-menus
      gtk2
      libgnomeui
      libxml2
    ];

    configureFlags = [
      "--disable-desktop-docs"
      "--disable-scrollkeeper"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 desktop library and data files";
      homepage = "https://download.gnome.org/sources/gnome-desktop/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libwnck = stdenv.mkDerivation rec {
    pname = "libwnck";
    version = "2.30.5";

    src = sources.libwnck;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libstartup_notification
      libx11
      libxext
      libxres
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 window navigator construction kit";
      homepage = "https://download.gnome.org/sources/libwnck/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gtksourceview = stdenv.mkDerivation rec {
    pname = "gtksourceview";
    version = "2.10.5";

    src = sources.gtksourceview;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Source code editing widget for GTK 2, used by gedit";
      homepage = "https://download.gnome.org/sources/gtksourceview/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gucharmap = stdenv.mkDerivation rec {
    pname = "gucharmap";
    version = "2.32.0";

    src = sources.gucharmap;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "@ENABLE_CHARMAP_TRUE@@HAVE_GNOME_DOC_UTILS_TRUE@am__append_2 = help" \
                        "@ENABLE_CHARMAP_TRUE@@HAVE_GNOME_DOC_UTILS_TRUE@am__append_2 ="
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      glib
      gtk2
    ];

    configureFlags = [
      "--disable-python-bindings"
      "--disable-introspection"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 Unicode character map application";
      homepage = "https://download.gnome.org/sources/gucharmap/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgtop = stdenv.mkDerivation rec {
    pname = "libgtop";
    version = "2.28.2";

    src = sources.libgtop;

    patches = [ ./patches/libgtop-modern-perl.patch ];

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [ glib ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "System usage/statistics library, used by gnome-system-monitor and panel applets";
      homepage = "https://download.gnome.org/sources/libgtop/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-keyring = stdenv.mkDerivation rec {
    pname = "gnome-keyring";
    version = "2.32.0";

    src = sources.gnome-keyring;

    patches = [ ./patches/gnome-keyring-modern-libtasn1.patch ];

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      dbus
      glib
      gtk2
      libgcrypt
      libtasn1
    ];

    configureFlags = [
      "--disable-pam"
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgio-2.0";
    };

    meta = {
      description = "GNOME 2 keyring daemon (secrets, SSH agent, GPG agent)";
      homepage = "https://download.gnome.org/sources/gnome-keyring/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  at-spi2-core = stdenv.mkDerivation rec {
    pname = "at-spi2-core";
    version = "0.4.0";

    src = sources.at-spi2-core;

    nativeBuildInputs = [
      gettext
      intltool
      pkg-config
    ];

    buildInputs = [
      dbus
      dbus-glib
      glib
      libXi
      libXtst
      libx11
    ];

    configureFlags = [
      "--with-dbus-daemondir=${dbus}/bin"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -fcommon";

    meta = {
      description = "Assistive Technology Service Provider Interface (D-Bus core)";
      homepage = "https://download.gnome.org/sources/at-spi2-core/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  at-spi2-atk = stdenv.mkDerivation rec {
    pname = "at-spi2-atk";
    version = "0.4.0";

    src = sources.at-spi2-atk;

    nativeBuildInputs = [
      gettext
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      at-spi2-core
      atk
      dbus
      dbus-glib
      glib
      gtk2
    ];

    env = {
      GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL = "1";
      NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";
    };

    meta = {
      description = "ATK to AT-SPI D-Bus accessibility bridge";
      homepage = "https://download.gnome.org/sources/at-spi2-atk/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gvfs = stdenv.mkDerivation rec {
    pname = "gvfs";
    version = "1.6.4";

    src = sources.gvfs;

    patches = [ ./patches/gvfs-pause-libc-conflict.patch ];

    nativeBuildInputs = [
      gettext
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus
      dbus-glib
      glib
      gnome-keyring
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 virtual filesystem infrastructure (successor to gnome-vfs)";
      homepage = "https://download.gnome.org/sources/gvfs/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  zenity = stdenv.mkDerivation rec {
    pname = "zenity";
    version = "2.32.0";

    src = sources.zenity;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail $'SUBDIRS = \\\n\tsrc\t\\\n\tpo\t\\\n\tdata\t\\\n\thelp' \
                        $'SUBDIRS = \\\n\tsrc\t\\\n\tpo\t\\\n\tdata'
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libx11
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 dialog-box scripting tool";
      homepage = "https://download.gnome.org/sources/zenity/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gcalctool = stdenv.mkDerivation rec {
    pname = "gcalctool";
    version = "5.32.0";

    src = sources.gcalctool;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = po src data help" "SUBDIRS = po src data"
    '';

    nativeBuildInputs = [
      bison
      flex
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 desktop calculator";
      homepage = "https://download.gnome.org/sources/gcalctool/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gconf-editor = stdenv.mkDerivation rec {
    pname = "gconf-editor";
    version = "2.32.0";

    src = sources.gconf-editor;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = data src po docs" "SUBDIRS = data src po"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      gtk2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 GConf configuration database editor";
      homepage = "https://download.gnome.org/sources/gconf-editor/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-nettool = stdenv.mkDerivation rec {
    pname = "gnome-nettool";
    version = "2.32.0";

    src = sources.gnome-nettool;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = pixmaps data src help po" "SUBDIRS = pixmaps data src po"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libgtop
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 network diagnostic tool";
      homepage = "https://download.gnome.org/sources/gnome-nettool/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-netstatus = stdenv.mkDerivation rec {
    pname = "gnome-netstatus";
    version = "2.28.2";

    src = sources.gnome-netstatus;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = src icons help po packaging" "SUBDIRS = src icons po packaging"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      gnome-panel
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libgnome
      libgnomecanvas
      popt
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-unused-result -Wno-error=format-security";
      NIX_LDFLAGS = "-lm";
    };

    meta = {
      description = "GNOME 2 network status panel applet";
      homepage = "https://download.gnome.org/sources/gnome-netstatus/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  bug-buddy = stdenv.mkDerivation rec {
    pname = "bug-buddy";
    version = "2.32.0";

    src = sources.bug-buddy;

    configureFlags = [
      "--disable-eds"
    ];

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      elfutils
      glib
      gtk2
      libbonobo
      libgtop
      libsoup
      libxml2
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 crash reporting tool";
      homepage = "https://download.gnome.org/sources/bug-buddy/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  file-roller = stdenv.mkDerivation rec {
    pname = "file-roller";
    version = "2.32.0";

    src = sources.file-roller;

    patches = [ ./patches/file-roller-glib-ptr-array-copy.patch ];

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = \\
	copy-n-paste	\\
	data		\\
	src		\\
	help		\\
	\$(NAUTILUS)	\\
	po" "SUBDIRS = \\
	copy-n-paste	\\
	data		\\
	src		\\
	\$(NAUTILUS)	\\
	po"
    '';

    configureFlags = [
      "--disable-nautilus-actions"
    ];

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libICE
      libSM
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 archive manager";
      homepage = "https://download.gnome.org/sources/file-roller/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  totem-pl-parser = stdenv.mkDerivation rec {
    pname = "totem-pl-parser";
    version = "2.32.0";

    src = sources.totem-pl-parser;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gmime
      libsoup
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Playlist parsing library used by Totem and other GNOME 2 media apps";
      homepage = "https://download.gnome.org/sources/totem-pl-parser/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  nautilus-sendto = stdenv.mkDerivation rec {
    pname = "nautilus-sendto";
    version = "2.32.0";

    src = sources.nautilus-sendto;

    configureFlags = [
      "--with-plugins=autodetect"
      "--with-nautilusdir=\${out}/lib/nautilus/extensions-2.0"
    ];

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      nautilus
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 nautilus 'Send To' context menu extension";
      homepage = "https://download.gnome.org/sources/nautilus-sendto/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gedit = stdenv.mkDerivation rec {
    pname = "gedit";
    version = "2.30.4";

    src = sources.gedit;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail '@OS_OSX_FALSE@am__append_1 = help' '@OS_OSX_FALSE@am__append_1 ='
    '';

    configureFlags = [
      "--disable-python"
      # Only enchant-2 (a different pkg-config name/API) is available;
      # nixpkgs dropped the old enchant 1.x this configure.ac checks for.
      "--disable-spell"
    ];

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      gtksourceview
      libICE
      libSM
      libx11
      libxml2
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0 -lICE";
    };

    meta = {
      description = "GNOME 2 text editor";
      homepage = "https://download.gnome.org/sources/gedit/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  eog = stdenv.mkDerivation rec {
    pname = "eog";
    version = "2.32.0";

    src = sources.eog;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail 'SUBDIRS = $(jpeg_DIRS) cut-n-paste bindings src plugins po help data doc' \
                        'SUBDIRS = $(jpeg_DIRS) cut-n-paste bindings src plugins po data doc'
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gnome-desktop
      gnome-icon-theme
      gtk2
      libICE
      libSM
      libexif
      librsvg
      libx11
      libxml2
      shared-mime-info
      zlib
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0 -lICE -lm";
    };

    meta = {
      description = "GNOME 2 image viewer";
      homepage = "https://download.gnome.org/sources/eog/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  seahorse = stdenv.mkDerivation rec {
    pname = "seahorse";
    version = "2.32.0";

    src = sources.seahorse;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "\$(SSH_DIR) \\
	src \\
	po \\
	data \\
	help \\" \
                        "\$(SSH_DIR) \\
	src \\
	po \\
	data \\"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      gnupg
      gpgme
      intltool
      openssh
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gnome-keyring
      gpgme
      gtk2
      libSM
      libgnome-keyring
      libsoup
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0";
    };

    meta = {
      description = "GNOME 2 GPG/SSH key manager";
      homepage = "https://download.gnome.org/sources/seahorse/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  seahorse-plugins = stdenv.mkDerivation rec {
    pname = "seahorse-plugins";
    version = "2.30.1";

    src = sources.seahorse-plugins;

    postPatch = ''
      sed -i '/^          help \\$/d' Makefile.in
      # configure only recognizes GnuPG 1.2/1.4/2.0 by major.minor; modern
      # GnuPG (2.4.x here) works fine with this codebase, the version list
      # is just stale.
      substituteInPlace configure \
        --replace-fail 'accepted_versions="1.2 1.4 2.0"' 'accepted_versions="1.2 1.4 2.0 2.2 2.4"'
      # The GPGME version check requires an exact major-version match
      # ("$major" -eq "$req_major"), so it rejects any GPGME 2.x since it
      # only knows about 1.0.0 as the minimum. Pin the minimum to the
      # actual major.minor.micro of the GPGME we're building against.
      substituteInPlace configure \
        --replace-fail 'min_gpgme_version=1.0.0' 'min_gpgme_version=${gpgme.version}'
      # GPGME 2.x dropped "trust items" entirely, so this event code no
      # longer exists; the switch case was only ever a no-op placeholder.
      sed -i '/case GPGME_EVENT_NEXT_TRUSTITEM:/d' libseahorse/seahorse-pgp-operation.c
    '';

    configureFlags = [ "--with-nautilus-ext-dir=\${out}/lib/nautilus/extensions-2.0" ];

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      gnupg
      gpgme
      intltool
      perlPackages.XMLParser
      pkg-config
      shared-mime-info
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gnome-panel
      gpgme
      gtk2
      libgnome-keyring
      nautilus
      seahorse
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 seahorse Nautilus/panel/agent integration plugins";
      homepage = "https://download.gnome.org/sources/seahorse-plugins/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  evince = stdenv.mkDerivation rec {
    pname = "evince";
    version = "2.32.0";

    src = sources.evince;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "properties shell po help \$(am__append_1)" "properties shell po \$(am__append_1)"
    '';

    configureFlags = [
      "--with-gtk=2.0"
      "--disable-introspection"
      "--disable-scrollkeeper"
      # nautilus's extensiondir is baked into evince's own $out install path
      # with no way to override it from configure, and points into
      # nautilus's own (read-only) store path; skip the integration plugin.
      "--disable-nautilus"
    ];

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      dbus
      dbus-glib
      glib
      gnome-icon-theme
      gtk2
      libgnome-keyring
      libICE
      libSM
      libxml2
      poppler
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0 -lICE";
    };

    meta = {
      description = "GNOME 2 document (PDF/PostScript) viewer";
      homepage = "https://download.gnome.org/sources/evince/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gtk-vnc = stdenv.mkDerivation rec {
    pname = "gtk-vnc";
    version = "0.6.0";

    src = sources.gtk-vnc;

    configureFlags = [
      "--with-gtk=2.0"
      "--without-sasl"
      "--without-pulseaudio"
      "--without-libview"
      "--without-python"
    ];

    nativeBuildInputs = [
      intltool
      pkg-config
    ];

    buildInputs = [
      gtk2
      gnutls
      libgcrypt
      libx11
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu99 -Wno-error=format-security -fcommon";

    meta = {
      description = "GTK2 VNC client widget (last GTK2-capable release; nixpkgs' is GTK3/meson-only)";
      homepage = "https://download.gnome.org/sources/gtk-vnc/";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.linux;
    };
  };

  vinagre = stdenv.mkDerivation rec {
    pname = "vinagre";
    version = "2.30.3";

    src = sources.vinagre;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = vinagre help po data plugins plugin-loaders" \
          "SUBDIRS = vinagre po data plugins plugin-loaders"
    '';

    configureFlags = [
      "--disable-ssh"
      "--disable-avahi"
    ];

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      dbus-glib
      glib
      gnome-panel
      gtk-vnc
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libgnome
      libgnomecanvas
      libgnome-keyring
      libx11
      libxml2
      popt
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";
      NIX_LDFLAGS = "-lgmodule-2.0";
    };

    meta = {
      description = "GNOME 2 VNC/RDP/SSH remote desktop client";
      homepage = "https://download.gnome.org/sources/vinagre/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  vino = stdenv.mkDerivation rec {
    pname = "vino";
    version = "2.32.0";

    src = sources.vino;

    postPatch = ''
      # notify_notification_new_with_status_icon() was removed from
      # libnotify along with the GtkStatusIcon-attach mechanism (same fix
      # as gnome-user-share's obexpush.c).
      perl -0777 -pi -e \
        's/notify_notification_new_with_status_icon \(summary,\s*\n\s*body,\s*\n\s*"preferences-desktop-remote-desktop",\s*\n\s*GTK_STATUS_ICON \(icon\)\);/notify_notification_new (summary,\n                                              body,\n                                              "preferences-desktop-remote-desktop");/' \
        server/vino-status-icon.c
    '';

    configureFlags = [
      # The vendored libvncserver/auth.c TLS code targets GnuTLS's old
      # (pre-2.12) key-exchange priority API, which no longer exists in
      # modern GnuTLS; VNC's own auth is already the weak link here, so
      # skip TLS rather than patch the vendored library's API usage.
      "--disable-gnutls"
    ];

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus
      dbus-glib
      glib
      gtk2
      libgnome-keyring
      libICE
      libjpeg
      libnotify
      libunique
      libsoup
      libSM
      zlib
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 VNC server (screen/remote-desktop sharing)";
      homepage = "https://download.gnome.org/sources/vino/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-user-share = stdenv.mkDerivation rec {
    pname = "gnome-user-share";
    version = "2.30.1";

    src = sources.gnome-user-share;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = data po src help" "SUBDIRS = data po src"
      # notify_notification_new_with_status_icon() was removed from
      # libnotify along with the GtkStatusIcon-attach mechanism; use the
      # plain 3-arg constructor instead (matches the fix already applied
      # to gnome-applets/gnome-color-manager/gnome-bluetooth call sites).
      substituteInPlace src/obexpush.c \
        --replace-fail \
          'notification = notify_notification_new_with_status_icon (_("You received a file"),
								 notification_text,
								 "dialog-information",
								 GTK_STATUS_ICON (statusicon));' \
          'notification = notify_notification_new (_("You received a file"),
								 notification_text,
								 "dialog-information");'
    '';

    configureFlags = [
      "--with-nautilusdir=\${out}/lib/nautilus/extensions-2.0"
    ];

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus
      dbus-glib
      glib
      gnome-bluetooth
      gtk2
      libcanberra
      libnotify
      libunique
      nautilus
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 personal file sharing (WebDAV/Bluetooth OBEX) integration";
      homepage = "https://download.gnome.org/sources/gnome-user-share/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-bluetooth = stdenv.mkDerivation rec {
    pname = "gnome-bluetooth";
    version = "2.32.0";

    src = sources.gnome-bluetooth;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = icons lib applet properties wizard sendto \$(MOBLIN_DIR) docs po help" \
          "SUBDIRS = icons lib applet properties wizard sendto \$(MOBLIN_DIR) docs po"
      # These <interface name="..."> values are only used by
      # dbus-binding-tool to derive generated C stub function names; the
      # real wire D-Bus interface strings (org.bluez.Manager etc.) are
      # hardcoded separately in bluetooth-client.c. Modern dbus-glib
      # rejects un-namespaced interface names outright, so give them a
      # (cosmetic-only) namespace.
      substituteInPlace lib/bluetooth-client.xml \
        --replace-fail 'interface name="manager"' 'interface name="gnomebt.manager"' \
        --replace-fail 'interface name="adapter"' 'interface name="gnomebt.adapter"' \
        --replace-fail 'interface name="device"' 'interface name="gnomebt.device"'
      # dbus-binding-tool derives its generated C function names from the
      # full dotted interface name, so namespacing it above changes the
      # sync call wrappers from e.g. manager_list_adapters() to
      # gnomebt_manager_list_adapters(); update the call sites to match.
      substituteInPlace lib/bluetooth-client.c \
        --replace-fail 'device_get_properties(device, &hash, NULL);' \
          'gnomebt_device_get_properties(device, &hash, NULL);' \
        --replace-fail 'adapter_get_properties(adapter, &hash, NULL);' \
          'gnomebt_adapter_get_properties(adapter, &hash, NULL);' \
        --replace-fail 'manager_list_adapters(priv->manager, &array, NULL);' \
          'gnomebt_manager_list_adapters(priv->manager, &array, NULL);' \
        --replace-fail 'manager_default_adapter(priv->manager, &default_path, NULL);' \
          'gnomebt_manager_default_adapter(priv->manager, &default_path, NULL);' \
        --replace-fail 'adapter_start_discovery(adapter, NULL);' \
          'gnomebt_adapter_start_discovery(adapter, NULL);' \
        --replace-fail 'adapter_stop_discovery(adapter, NULL);' \
          'gnomebt_adapter_stop_discovery(adapter, NULL);'
      substituteInPlace lib/test-agent.c \
        --replace-fail 'device_get_properties(device, &hash, NULL);' \
          'gnomebt_device_get_properties(device, &hash, NULL);'
      substituteInPlace applet/notify.c \
        --replace-fail \
          'notify = notify_notification_new(summary, message, icon_name, NULL);' \
          'notify = notify_notification_new(summary, message, icon_name);'
    '';

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      libxml2
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gtk2
      libnotify
      libunique
      libXi
      libx11
      nautilus-sendto
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 Bluetooth device management (applet, wizard, properties)";
      homepage = "https://download.gnome.org/sources/gnome-bluetooth/";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-color-manager = stdenv.mkDerivation rec {
    pname = "gnome-color-manager";
    version = "2.32.0";

    src = sources.gnome-color-manager;

    postPatch = ''
      sed -i '/^\thelp\t*\\$/d' Makefile.in
      # libnotify 0.7 dropped notify_notification_new's trailing
      # GtkWidget *attach argument.
      substituteInPlace src/gcm-session.c \
        --replace-fail \
          'notify_notification_new (title, message, GCM_STOCK_ICON, NULL);' \
          'notify_notification_new (title, message, GCM_STOCK_ICON);'
    '';

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gnome-desktop
      gtk2
      lcms1
      libcanberra
      libgudev
      libnotify
      libunique
      libx11
      libxrandr
      libxxf86vm
      sane-backends
      vte
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 color management/calibration utilities";
      homepage = "https://download.gnome.org/sources/gnome-color-manager/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-utils = stdenv.mkDerivation rec {
    pname = "gnome-utils";
    version = "2.32.0";

    src = sources.gnome-utils;

    postPatch = ''
      substituteInPlace configure \
        --replace-fail \
          'as_fn_error "Couldn'"'"'t find scrollkeeper-config. Please install the scrollkeeper package" "$LINENO" 5' \
          ':'
      substituteInPlace baobab/Makefile.in \
        --replace-fail "SUBDIRS = src data pixmaps help" "SUBDIRS = src data pixmaps"
      substituteInPlace logview/Makefile.in \
        --replace-fail "SUBDIRS = data help tests" "SUBDIRS = data tests"
      substituteInPlace gsearchtool/Makefile.in \
        --replace-fail "SUBDIRS = data help libgnomeui-deprecated" "SUBDIRS = data libgnomeui-deprecated"
      substituteInPlace gnome-dictionary/Makefile.in \
        --replace-fail "SUBDIRS = libgdict src data docs help" "SUBDIRS = libgdict src data"
      # nixpkgs' libcanberra in this snapshot only wires up a GTK3 module
      # (gtkSupport = "gtk3"), so libcanberra-gtk.pc (the GTK2 ABI this
      # package needs) doesn't exist. gnome-screenshot only uses the GTK
      # wrapper for ca_gtk_context_get(), a thin convenience helper around
      # plain ca_context_create()/ca_context_open(); use the core
      # (non-GTK) libcanberra API and pkg-config module instead.
      substituteInPlace configure \
        --replace-fail "libcanberra-gtk >= \$LIBCANBERRA_GTK_REQUIRED" "libcanberra >= \$LIBCANBERRA_GTK_REQUIRED"
      substituteInPlace gnome-screenshot/gnome-screenshot.c \
        --replace-fail "#include <canberra-gtk.h>" "#include <canberra.h>" \
        --replace-fail "c = ca_gtk_context_get ();" \
          "ca_context_create (&c); ca_context_open (c);"
      # gdict-client-context.h uses the GdictContext type in its own
      # prototypes without including the header that defines it; only ever
      # worked because every prior consumer happened to include
      # gdict-context.h first through some other path.
      substituteInPlace gnome-dictionary/libgdict/gdict-client-context.h \
        --replace-fail '#include <glib-object.h>' \
          '#include <glib-object.h>
#include "gdict-context.h"'
      # gsearchtool's libgnomeui-deprecated subdir vendors a subclass of
      # the deprecated GtkComboBoxEntry widget, but its own Makefile
      # disables deprecated GTK API for that exact compilation, which
      # hides the very type it subclasses.
      substituteInPlace gsearchtool/libgnomeui-deprecated/Makefile.in \
        --replace-fail 'INCLUDES = -DGTK_DISABLE_DEPRECATED \
           -DGDK_DISABLE_DEPRECATED \
           -DG_DISABLE_DEPRECATED' \
          'INCLUDES ='
    '';

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      ORBit2
      dbus-glib
      glib
      gnome-icon-theme
      gnome-panel
      gtk2
      libSM
      libart_lgpl
      libbonobo
      libbonoboui
      libcanberra
      libgnome
      libgnomecanvas
      libgnomeui
      libgtop
      libx11
      libxext
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=format-security -fcommon";

    meta = {
      description = "GNOME 2 utilities: baobab, gnome-dictionary, gnome-screenshot, gsearchtool, logview";
      homepage = "https://download.gnome.org/sources/gnome-utils/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-applets = stdenv.mkDerivation rec {
    pname = "gnome-applets";
    version = "2.32.0";

    src = sources.gnome-applets;

    configureFlags = [
      # setuid-root install of cpufreq-selector isn't possible (and isn't
      # meaningful) inside the Nix build sandbox.
      "--disable-suid"
    ];

    postPatch = ''
      # scrollkeeper is a long-dead docs indexer with no modern equivalent
      # packaged; SCROLLKEEPER_CONFIG is only ever AC_SUBST'd, never used to
      # build or link anything, so the hard failure here is safe to drop.
      # (The generated error message is also malformed -- an unquoted,
      # space-containing AC_MSG_ERROR argument confuses as_fn_error's
      # arg parsing -- an upstream autoconf-generation bug independent of
      # the scrollkeeper check itself.)
      substituteInPlace configure \
        --replace-fail 'if test x$SCROLLKEEPER_CONFIG = xno; then
  as_fn_error please install the Scrollkeeper 0.1.4 package "Couldn'"'"'t find scrollkeeper-config" "$LINENO" 5
fi' ':'
      # Per-applet docs/help dirs go through gnome-doc-utils' OMF metadata
      # generation, which shells out to the real scrollkeeper-config tool
      # (long dead upstream, no modern nixpkgs equivalent) to locate a
      # Templates/scrollkeeper_cl.xml file used by the OMF stylesheet; drop
      # each applet's docs/help subdir rather than stub out scrollkeeper.
      substituteInPlace charpick/Makefile.in gswitchit/Makefile.in drivemount/Makefile.in \
        --replace-fail "SUBDIRS = help" "SUBDIRS ="
      substituteInPlace mixer/Makefile.in gweather/Makefile.in multiload/Makefile.in \
        --replace-fail "SUBDIRS = docs" "SUBDIRS ="
      substituteInPlace trashapplet/Makefile.in \
        --replace-fail "SUBDIRS = src docs" "SUBDIRS = src"
      substituteInPlace geyes/Makefile.in \
        --replace-fail "SUBDIRS = themes docs" "SUBDIRS = themes"
      substituteInPlace stickynotes/Makefile.in \
        --replace-fail "SUBDIRS = pixmaps docs data" "SUBDIRS = pixmaps data"
      substituteInPlace mini-commander/Makefile.in \
        --replace-fail "SUBDIRS = src help" "SUBDIRS = src"
      substituteInPlace cpufreq/Makefile.in \
        --replace-fail "SUBDIRS = help pixmaps src" "SUBDIRS = pixmaps src"
      substituteInPlace battstat/Makefile.in \
        --replace-fail 'SUBDIRS = docs sounds $(APMDIR)' 'SUBDIRS = sounds $(APMDIR)'
      substituteInPlace accessx-status/Makefile.in \
        --replace-fail "SUBDIRS = docs pixmaps" "SUBDIRS = pixmaps"
      substituteInPlace invest-applet/Makefile.in \
        --replace-fail "SUBDIRS = invest data docs" "SUBDIRS = invest data"
      # libnotify 0.7 dropped notify_notification_new's trailing
      # GtkWidget *attach argument; drop it at the two call sites.
      substituteInPlace battstat/battstat_applet.c \
        --replace-fail \
          'notify_notification_new (_("Your battery is now fully recharged"), "", /* "battery" */ NULL, applet);' \
          'notify_notification_new (_("Your battery is now fully recharged"), "", /* "battery" */ NULL);'
      substituteInPlace gweather/gweather-applet.c \
        --replace-fail \
          'n = notify_notification_new (message, detail, icon,
					 gw_applet->container);' \
          'n = notify_notification_new (message, detail, icon);'
    '';

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      libxslt
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      ORBit2
      dbus
      dbus-glib
      glib
      gnome-desktop
      gnome-icon-theme
      gnome-panel
      gnome-settings-daemon
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libgnome
      libgnomecanvas
      libgtop
      libgweather
      libICE
      libnotify
      libSM
      libwnck
      libxml2
      libxklavier
      popt
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89 -fcommon";
      NIX_LDFLAGS = "-lm -lX11";
    };

    meta = {
      description = "GNOME 2 desktop panel applets";
      homepage = "https://download.gnome.org/sources/gnome-applets/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gtkmm2 = stdenv.mkDerivation rec {
    pname = "gtkmm";
    version = "2.24.5";

    src = sources.gtkmm2;

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      atkmm
      cairomm
      glibmm
      gtk2
      pangomm
    ];

    meta = {
      description = "C++ bindings for GTK+ 2 (gtkmm-2.4)";
      homepage = "https://download.gnome.org/sources/gtkmm/";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-system-monitor = stdenv.mkDerivation rec {
    pname = "gnome-system-monitor";
    version = "2.28.2";

    src = sources.gnome-system-monitor;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = pixmaps po src help" "SUBDIRS = pixmaps po src"
      # C++11 added rvalue-reference operator<< overloads for ostream, so a
      # temporary ostringstream's operator<< result no longer statically
      # converts back to ostringstream& the way this pre-C++11-era code
      # assumed; build the string in two steps instead.
      substituteInPlace src/lsof.cpp \
        --replace-fail \
          'string s = static_cast<std::ostringstream&>(std::ostringstream() << count).str();' \
          'std::ostringstream ss; ss << count; string s = ss.str();'
    '';

    nativeBuildInputs = [
      gnomeDocUtils
      intltool
      pkg-config
    ];

    buildInputs = [
      GConf
      atkmm
      cairomm
      dbus-glib
      glib
      glibmm
      gnome-icon-theme
      gtk2
      gtkmm2
      libgtop
      librsvg
      libwnck
      libxml2
      pangomm
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu++11";
      NIX_LDFLAGS = "-lgmodule-2.0";
    };

    meta = {
      description = "GNOME 2 process/resource/file-system monitor";
      homepage = "https://download.gnome.org/sources/gnome-system-monitor/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  mousetweaks = stdenv.mkDerivation rec {
    pname = "mousetweaks";
    version = "2.32.0";

    src = sources.mousetweaks;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = src data pixmaps po help man" "SUBDIRS = src data pixmaps po man"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      ORBit2
      glib
      gnome-panel
      gtk2
      libXtst
      libart_lgpl
      libbonobo
      libbonoboui
      libgnome
      libgnomecanvas
      libxcursor
      libxfixes
      popt
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 mouse accessibility enhancements (dwell click, pointer capture)";
      homepage = "https://download.gnome.org/sources/mousetweaks/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  vte = stdenv.mkDerivation rec {
    pname = "vte";
    version = "0.26.0";

    src = sources.vte;

    nativeBuildInputs = [
      gettext
      intltool
      pkg-config
    ];

    buildInputs = [
      glib
      gtk2
      ncurses
    ];

    configureFlags = [
      "--disable-python"
      "--disable-gnome-pty-helper"
      "--disable-gtk-doc"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Terminal emulator widget for GTK 2";
      homepage = "https://download.gnome.org/sources/vte/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  # GTK 2's own build tool for converting libglade .glade files to
  # GtkBuilder .ui files. It shipped in the gtk+ source tree itself but
  # current nixpkgs no longer installs it, and gnome-terminal's build still
  # needs it, so pull the one script out of the same gtk2 source tarball
  # nixpkgs already fetches for gtk2 rather than adding a new source.
  gtkBuilderConvert = stdenv.mkDerivation {
    pname = "gtk-builder-convert";
    version = gtk2.version;

    src = gtk2.src;

    nativeBuildInputs = [ python3 ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      install -m755 gtk/gtk-builder-convert $out/bin/gtk-builder-convert
      patchShebangs $out/bin/gtk-builder-convert
    '';

    meta = {
      description = "Converts libglade .glade files to GtkBuilder .ui files";
      homepage = "https://gitlab.gnome.org/GNOME/gtk";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  metacity = stdenv.mkDerivation rec {
    pname = "metacity";
    version = "2.30.3";

    src = sources.metacity;

    patches = [
      ./patches/metacity-disable-canberra.patch
      ./patches/metacity-fallback-default-icon.patch
    ];

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libstartup_notification
      libwnck
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxrender
      zenity
    ];

    configureFlags = [
      "--disable-compositor"
      "--disable-scrollkeeper"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "Metacity window manager for GNOME 2";
      homepage = "https://download.gnome.org/sources/metacity/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-session = stdenv.mkDerivation rec {
    pname = "gnome-session";
    version = "2.32.0";

    src = sources.gnome-session;

    patches = [ ./patches/gnome-session-disable-obsolete-upower-actions.patch ];

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gtk2
      libgnomeui
      libSM
      libstartup_notification
      libx11
      upower
    ];

    env = {
      GCONF_SANITY_CHECK = "${coreutils}/bin/true";
      NIX_CFLAGS_COMPILE = "-std=gnu89";
    };

    meta = {
      description = "GNOME 2 session manager";
      homepage = "https://download.gnome.org/sources/gnome-session/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-panel = stdenv.mkDerivation rec {
    pname = "gnome-panel";
    version = "2.32.0.2";

    src = sources.gnome-panel;

    patches = [ ./patches/gnome-panel-disable-canberra.patch ];

    postPatch = ''
      substituteInPlace configure configure.ac \
        --replace-fail " libcanberra-gtk" ""
      substituteInPlace Makefile.in \
        --replace-fail "doc help icons" "doc icons"
      # bonobo/panel-module's Makefile.am builds libpanel_applets_bonobo_la
      # from just $(BONOBO_CFLAGS) (ORBit-2.0 + libbonoboui-2.0), but
      # panel-applets-bonobo-module.c pulls in panel-gconf.h transitively
      # through applet.h. $(LIBPANEL_APPLET_BONOBO_CFLAGS) -- which does
      # include gconf-2.0 -- is already substituted into this Makefile.in
      # (used elsewhere in it), just not wired into this CPPFLAGS list; a
      # real upstream oversight in this rarely-built legacy compat path.
      sed -i '/^libpanel_applets_bonobo_la_CPPFLAGS = \\$/{n;s/$/\n\t$(LIBPANEL_APPLET_BONOBO_CFLAGS)\t\\/}' \
        bonobo/panel-module/Makefile.in
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
      python3
      which
    ];

    buildInputs = [
      GConf
      ORBit2
      dbus-glib
      glib
      gnome-desktop
      gnome-menus
      gtk2
      libart_lgpl
      libbonobo
      libbonoboui
      libgnome
      libgnomecanvas
      libgnomeui
      libgweather
      libICE
      librsvg
      libSM
      libwnck
      libx11
      libxml2
      popt
    ];

    configureFlags = [
      "--disable-scrollkeeper"
      "--enable-bonobo"
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0 -lm -lX11";
    };

    meta = {
      description = "GNOME 2 desktop panel";
      homepage = "https://download.gnome.org/sources/gnome-panel/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgweather = stdenv.mkDerivation rec {
    pname = "libgweather";
    version = "2.30.3";

    src = sources.libgweather;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libsoup
      libxml2
    ];

    configureFlags = [
      "--with-zoneinfo-dir=${tzdata}/share/zoneinfo"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 weather library";
      homepage = "https://download.gnome.org/sources/libgweather/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libsoup = stdenv.mkDerivation rec {
    pname = "libsoup";
    version = "2.32.0";

    src = sources.libsoup;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      libgnome-keyring
      libproxy
      libxml2
      sqlite
    ];

    configureFlags = [
      "--disable-ssl"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 HTTP client/server library";
      homepage = "https://download.gnome.org/sources/libsoup/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libunique = stdenv.mkDerivation rec {
    pname = "libunique";
    version = "1.1.6";

    src = sources.libunique;

    hardeningDisable = [ "format" ];

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      dbus-glib
      glib
      gtk2
    ];

    configureFlags = [
      "--enable-debug=no"
      "--enable-maintainer-flags=no"
      "--disable-dbus"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error=deprecated-declarations";

    meta = {
      description = "Single instance support library for GTK 2 applications";
      homepage = "https://download.gnome.org/sources/libunique/";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.linux;
    };
  };

  nautilus = stdenv.mkDerivation rec {
    pname = "nautilus";
    version = "2.32.0";

    src = sources.nautilus;

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
      shared-mime-info
    ];

    buildInputs = [
      GConf
      glib
      gnome-desktop
      gnome-menus
      gnome-vfs
      gtk2
      libexif
      libgnomeui
      libICE
      libSM
      libunique
      libxml2
    ];

    configureFlags = [
      "--disable-scrollkeeper"
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0";
    };

    meta = {
      description = "GNOME 2 file manager";
      homepage = "https://download.gnome.org/sources/nautilus/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-terminal = stdenv.mkDerivation rec {
    pname = "gnome-terminal";
    version = "2.32.0";

    src = sources.gnome-terminal;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = src po help" "SUBDIRS = src po"
    '';

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      gtkBuilderConvert
      intltool
      perlPackages.XMLParser
      pkg-config
      which
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libICE
      libSM
      vte
    ];

    env = {
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lICE";
    };

    meta = {
      description = "GNOME 2 terminal emulator application";
      homepage = "https://download.gnome.org/sources/gnome-terminal/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-settings-daemon = stdenv.mkDerivation rec {
    pname = "gnome-settings-daemon";
    version = "2.32.0";

    src = sources.gnome-settings-daemon;

    nativeBuildInputs = [
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      dbus-glib
      glib
      gnome-desktop
      gtk2
      libgnomekbd
      libgnomeui
      libICE
      libSM
      libx11
      libxklavier
    ];

    configureFlags = [
      "--disable-scrollkeeper"
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 settings daemon";
      homepage = "https://download.gnome.org/sources/gnome-settings-daemon/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  libgnomekbd = stdenv.mkDerivation rec {
    pname = "libgnomekbd";
    version = "2.32.0";

    src = sources.libgnomekbd;

    nativeBuildInputs = [
      gettext
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    buildInputs = [
      GConf
      glib
      gtk2
      libxklavier
      libxml2
    ];

    env.NIX_CFLAGS_COMPILE = "-std=gnu89";

    meta = {
      description = "GNOME 2 keyboard configuration library";
      homepage = "https://download.gnome.org/sources/libgnomekbd/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-control-center = stdenv.mkDerivation rec {
    pname = "gnome-control-center";
    version = "2.32.0";

    src = sources.gnome-control-center;

    postPatch = ''
      substituteInPlace Makefile.in \
        --replace-fail "SUBDIRS = po libwindow-settings capplets font-viewer help \\" \
                        "SUBDIRS = po libwindow-settings capplets font-viewer \\"
    '';

    nativeBuildInputs = [
      desktop-file-utils
      gettext
      gnomeDocUtils
      intltool
      perlPackages.XMLParser
      pkg-config
      shared-mime-info
      which
    ];

    buildInputs = [
      GConf
      dbus
      dbus-glib
      glib
      gnome-desktop
      gnome-menus
      gnome-settings-daemon
      gtk2
      libSM
      libXScrnSaver
      libXi
      libcanberra
      libgnomekbd
      libunique
      libxcursor
      libxklavier
      libxml2
      libx11
      metacity
    ];

    configureFlags = [
      "--disable-update-mimedb"
    ];

    # configure hardcodes GTK_ENGINE_DIR to plain gtk2's own libdir
    # (`pkg-config --variable libdir gtk+-2.0`), baked in via -D as a
    # compile-time C string. Since our engines (Clearlooks etc.) live in
    # the separately-packaged gtkEngines derivation, not in gtk2's own
    # store path, the Appearance capplet's engine-presence check always
    # reports themes as "not installed" even though GTK_PATH makes them
    # load and render fine at runtime. Override the Makefile variable
    # (recursive `=` assignment, so a command-line override wins) to
    # point the diagnostic at where the engines actually are.
    makeFlags = [
      "GTK_ENGINE_DIR=${gtkEngines}/lib/gtk-2.0/2.10.0/engines"
    ];

    env = {
      GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL = "1";
      NIX_CFLAGS_COMPILE = "-std=gnu89";
      NIX_LDFLAGS = "-lgmodule-2.0";
    };

    meta = {
      description = "GNOME 2 control center and preference capplets";
      homepage = "https://download.gnome.org/sources/gnome-control-center/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  gnome-icon-theme = stdenv.mkDerivation rec {
    pname = "gnome-icon-theme";
    version = "2.31.0";

    src = sources.gnome-icon-theme;

    nativeBuildInputs = [
      iconnamingutils
      intltool
      perlPackages.XMLParser
      pkg-config
    ];

    meta = {
      description = "GNOME 2 icon theme";
      homepage = "https://download.gnome.org/sources/gnome-icon-theme/";
      license = lib.licenses.gpl2Only;
      platforms = lib.platforms.linux;
    };
  };

  gnome-themes = stdenv.mkDerivation rec {
    pname = "gnome-themes";
    version = "2.32.0";

    src = sources.gnome-themes;

    nativeBuildInputs = [
      gettext
      iconnamingutils
      intltool
      pkg-config
    ];

    buildInputs = [
      gtk2
      gtkEngines
    ];

    meta = {
      description = "GNOME 2 GTK, metacity and icon themes";
      homepage = "https://download.gnome.org/sources/gnome-themes/";
      license = lib.licenses.lgpl2Plus;
      platforms = lib.platforms.linux;
    };
  };
in
rec {
  inherit GConf ORBit2 at-spi2-atk at-spi2-core bug-buddy file-roller gcalctool gconf-editor gdm gnome-backgrounds gnome-control-center gnome-desktop gnome-icon-theme gnome-icon-theme-symbolic gnome-keyring gnome-menus gnome-mime-data gnome-netstatus gnome-nettool gnome-panel gnome-session gnome-settings-daemon gnome-terminal gnome-themes gnome-vfs gtkBuilderConvert gtkEngines gtksourceview gucharmap gvfs libIDL libart_lgpl libbonobo libbonoboui libglade libgnome libgnome-keyring libgnomecanvas libgnomekbd libgnomeprint libgnomeprintui libgnomeui libgtop libgweather libsoup libunique libwnck metacity mousetweaks nautilus nautilus-sendto eog evince gedit gnome-applets gnome-bluetooth gnome-color-manager gnome-system-monitor gnome-user-share gnome-utils gtk-vnc gtkmm2 libcanberra seahorse seahorse-plugins totem-pl-parser vinagre vino vte zenity;

  gnome2-core = buildEnv {
    name = "gnome2-core";
    paths = [
      GConf
      ORBit2
      at-spi2-atk
      at-spi2-core
      bug-buddy
      gcalctool
      gconf-editor
      gnome-control-center
      gnome-desktop
      gnome-applets
      gnome-bluetooth
      gnome-color-manager
      gnome-user-share
      gtk-vnc
      vinagre
      vino
      gnome-utils
      libcanberra
      gnome-mime-data
      gnome-menus
      gnome-netstatus
      gnome-nettool
      gnome-panel
      gnome-session
      gnome-settings-daemon
      gnome-vfs
      gdm
      gnome-backgrounds
      gnome-icon-theme
      gnome-icon-theme-symbolic
      gnome-keyring
      xcursor-themes
      gnome-terminal
      gnome-themes
      gtkEngines
      gtksourceview
      gucharmap
      gvfs
      mousetweaks
      zenity
      libart_lgpl
      libbonobo
      libbonoboui
      libglade
      libgnome
      libgnome-keyring
      libgnomecanvas
      libgnomekbd
      libgnomeprint
      libgnomeprintui
      libgnomeui
      libgtop
      libgweather
      libsoup
      libunique
      libwnck
      metacity
      nautilus
      nautilus-sendto
      vte
      eog
      evince
      file-roller
      gedit
      gnome-system-monitor
      gtkBuilderConvert
      gtkmm2
      seahorse
      seahorse-plugins
      totem-pl-parser
    ];
  };
}
