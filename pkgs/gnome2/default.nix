{
  lib,
  stdenv,
  fetchurl,
  bison,
  buildEnv,
  bzip2,
  dbus-glib,
  flex,
  gettext,
  glib,
  gtk2,
  iconnamingutils,
  intltool,
  libcanberra,
  libgcrypt,
  pkg-config,
  libxml2,
  perlPackages,
  popt,
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
  inherit GConf ORBit2 gnome-icon-theme gnome-mime-data gnome-vfs libIDL libart_lgpl libbonobo libbonoboui libglade libgnome libgnome-keyring libgnomecanvas libgnomeui;

  gnome2-core = buildEnv {
    name = "gnome2-core";
    paths = [
      GConf
      ORBit2
      gnome-mime-data
      gnome-vfs
      gnome-icon-theme
      libart_lgpl
      libbonobo
      libbonoboui
      libglade
      libgnome
      libgnome-keyring
      libgnomecanvas
      libgnomeui
    ];
  };
}
