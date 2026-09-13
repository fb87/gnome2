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
            atk
            bison
            buildEnv
            bzip2
            coreutils
            dbus
            dbus-glib
            desktop-file-utils
            elfutils
            fetchurl
            fontconfig
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
            libtasn1
            libx11
            libxcomposite
            libxcursor
            libxdamage
            libxext
            libxfixes
            libXi
            libxklavier
            libXScrnSaver
            libXtst
            libxrender
            libxres
            libxml2
            ncurses
            pango
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
