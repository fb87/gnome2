{
  lib,
  stdenv,
  fetchurl,
  bison,
  buildEnv,
  dbus-glib,
  flex,
  gettext,
  glib,
  iconnamingutils,
  intltool,
  pkg-config,
  libxml2,
  perlPackages,
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
  inherit GConf ORBit2 gnome-icon-theme libIDL;

  gnome2-core = buildEnv {
    name = "gnome2-core";
    paths = [
      GConf
      ORBit2
      gnome-icon-theme
    ];
  };
}
