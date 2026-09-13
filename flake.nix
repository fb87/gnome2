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
            atkmm
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
            glibmm
            gmime
            gnupg
            gnutls
            gpgme
            openssh
            gtk2
            iconnamingutils
            intltool
            lib
            libexif
            lcms1
            libgcrypt
            libjpeg
            libgudev
            libICE
            libnotify
            libtool
            libvorbis
            librsvg
            libSM
            libstartup_notification
            libproxy
            libtasn1
            sqlite
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
            libxrandr
            libxxf86vm
            libxml2
            libxslt
            ncurses
            pango
            pangomm
            perlPackages
            popt
            pkg-config
            poppler
            sane-backends
            python3
            shared-mime-info
            stdenv
            tzdata
            upower
            which
            zenity
            zlib;
          # gnome-doc-utils installs its xml2po Python module under
          # lib/python3.1/site-packages (a stale hardcoded version string
          # from its own build scripts) but the xml2po wrapper never adds
          # that directory to PYTHONPATH, so `from xml2po import Main`
          # fails for every consumer's help/docs translation step.
          gnomeDocUtils = pkgs.gnome-doc-utils.overrideAttrs (old: {
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/xml2po \
                --prefix PYTHONPATH : $out/lib/python3.1/site-packages
            '';
          });
          cairomm = pkgs.cairomm_1_0;
        };
      in
      gnome2 // {
        default = gnome2.gnome2-core;
      }) inputs.nixpkgs.legacyPackages;
  };
}
