{
  description = "Gnome 2 - Back for good";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs:
      let
        gnome2 = import ./pkgs/gnome2 {
          inherit (pkgs)
            bison
            buildEnv
            bzip2
            dbus-glib
            fetchurl
            flex
            gettext
            glib
            iconnamingutils
            intltool
            lib
            libcanberra
            libxml2
            perlPackages
            popt
            pkg-config
            stdenv;
        };
      in
      gnome2 // {
        default = gnome2.gnome2-core;
      }) inputs.nixpkgs.legacyPackages;
  };
}
