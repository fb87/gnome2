{ fetchurl }:

let
  desktopSource = name: hash:
    fetchurl {
      url = "https://download.gnome.org/desktop/2.32/2.32.0/sources/${name}";
      inherit hash;
    };

  gnomeSource = project: branch: name: hash:
    fetchurl {
      url = "https://download.gnome.org/sources/${project}/${branch}/${name}";
      inherit hash;
    };
in
{
  GConf = gnomeSource "GConf" "2.32" "GConf-2.32.0.tar.bz2" "sha256-VN0d1/SZKKnMQldL727wSBdTdw/BmYbcIAS7t/rJd6A=";
  libIDL = gnomeSource "libIDL" "0.8" "libIDL-0.8.14.tar.bz2" "sha256-xdJNjAllRjU/vHzt8gg5LVoCr+nVbrzBzMsljXxNIiA=";
  ORBit2 = gnomeSource "ORBit2" "2.14" "ORBit2-2.14.19.tar.bz2" "sha256-VckAqQVIKZJzD1dfPu801QvacXwZfJfAj6Wm6v2FdVA=";
  gnome-icon-theme = desktopSource "gnome-icon-theme-2.31.0.tar.bz2" "sha256-6n4Ft36tFZN5OSs7J1ygycus19k2AU5EfMfF4np2eYI=";
}
