{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  iconnamingutils,
  intltool,
  pkg-config,
  perlPackages,
}:

let
  sources = import ./sources.nix { inherit fetchurl; };

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
  inherit gnome-icon-theme;

  gnome2-core = buildEnv {
    name = "gnome2-core";
    paths = [
      gnome-icon-theme
    ];
  };
}
