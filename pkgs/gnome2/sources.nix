{ fetchurl }:

let
  desktopSource = name: hash:
    fetchurl {
      url = "https://download.gnome.org/desktop/2.32/2.32.0/sources/${name}";
      inherit hash;
    };
in
{
  gnome-icon-theme = desktopSource "gnome-icon-theme-2.31.0.tar.bz2" "sha256-6n4Ft36tFZN5OSs7J1ygycus19k2AU5EfMfF4np2eYI=";
}
