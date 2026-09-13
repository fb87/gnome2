{
  lib,
  stdenv,
  fetchurl,
  bison,
  buildEnv,
  bzip2,
  coreutils,
  dbus-glib,
  flex,
  gettext,
  glib,
  gtk2,
  gnomeDocUtils,
  iconnamingutils,
  intltool,
  libcanberra,
  libexif,
  libgcrypt,
  libICE,
  librsvg,
  libSM,
  libstartup_notification,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxklavier,
  libxrender,
  libxres,
  pkg-config,
  libxml2,
  perlPackages,
  popt,
  python3,
  shared-mime-info,
  tzdata,
  upower,
  which,
  zenity,
}:

let
  sources = import ./sources.nix { inherit fetchurl; };

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
      dbus-glib
      glib
      gnome-desktop
      gnome-menus
      gtk2
      libbonoboui
      libgnomeui
      libgweather
      libICE
      librsvg
      libSM
      libwnck
      libx11
      libxml2
    ];

    configureFlags = [
      "--disable-scrollkeeper"
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
      glib
      libxml2
    ];

    configureFlags = [
      "--disable-ssl"
      "--without-gnome"
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
in
rec {
  inherit GConf ORBit2 gnome-desktop gnome-icon-theme gnome-menus gnome-mime-data gnome-panel gnome-session gnome-settings-daemon gnome-vfs libIDL libart_lgpl libbonobo libbonoboui libglade libgnome libgnome-keyring libgnomecanvas libgnomekbd libgnomeui libgweather libsoup libunique libwnck metacity nautilus;

  gnome2-core = buildEnv {
    name = "gnome2-core";
    paths = [
      GConf
      ORBit2
      gnome-desktop
      gnome-mime-data
      gnome-menus
      gnome-panel
      gnome-session
      gnome-settings-daemon
      gnome-vfs
      gnome-icon-theme
      libart_lgpl
      libbonobo
      libbonoboui
      libglade
      libgnome
      libgnome-keyring
      libgnomecanvas
      libgnomekbd
      libgnomeui
      libgweather
      libsoup
      libunique
      libwnck
      metacity
      nautilus
    ];
  };
}
