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
            coreutils
            dbus-glib
            fetchurl
            flex
            gettext
            glib
            gtk2
            iconnamingutils
            intltool
            lib
            libcanberra
            libexif
            libgcrypt
            libICE
            librsvg
            libSM
            libstartup_notification
            libx11
            libxcomposite
            libxcursor
            libxdamage
            libxext
            libxfixes
            libxklavier
            libxrender
            libxres
            libxml2
            perlPackages
            popt
            pkg-config
            python3
            shared-mime-info
            stdenv
            tzdata
            upower
            which
            zenity;
          gnomeDocUtils = pkgs.gnome-doc-utils;
        };
      in
      gnome2 // {
        default = gnome2.gnome2-core;
      }) inputs.nixpkgs.legacyPackages;
  };
}
