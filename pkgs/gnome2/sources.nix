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
  gnome-mime-data = gnomeSource "gnome-mime-data" "2.18" "gnome-mime-data-2.18.0.tar.bz2" "sha256-NxlrWzcIW7zUXDOMNuJomP413Vl1KV9p9IAosehDb9c=";
  gnome-vfs = gnomeSource "gnome-vfs" "2.24" "gnome-vfs-2.24.4.tar.bz2" "sha256-Yt5ktbgE6wQQT/mPzWqLcnbVEKSfvZwP61aPiZZET6o=";
  libIDL = gnomeSource "libIDL" "0.8" "libIDL-0.8.14.tar.bz2" "sha256-xdJNjAllRjU/vHzt8gg5LVoCr+nVbrzBzMsljXxNIiA=";
  libart_lgpl = gnomeSource "libart_lgpl" "2.3" "libart_lgpl-2.3.21.tar.bz2" "sha256-/cEedMEPyf/kGIU34rNwwKusyn2JAh1NMDr99/10dvo=";
  libbonobo = gnomeSource "libbonobo" "2.32" "libbonobo-2.32.0.tar.bz2" "sha256-uLgDfV6ON/OTlaKi+6fy+z1bU+ztw9QZGBkSuDGrE0k=";
  libbonoboui = gnomeSource "libbonoboui" "2.24" "libbonoboui-2.24.5.tar.bz2" "sha256-+rXyrGyELZSYYcB8tSCv5b7j3OVYBRUc6c0Bvg7Eb80=";
  libglade = gnomeSource "libglade" "2.6" "libglade-2.6.4.tar.bz2" "sha256-ZDYedkeDnTbtgzbZkv0hDT6BOYgiab7UfcRnSYAWXew=";
  libgnome = gnomeSource "libgnome" "2.32" "libgnome-2.32.0.tar.bz2" "sha256-1l5JvwdesrPv6+w4zrQJaTFU0YOWNldl2hpxYwvD3QI=";
  libgnome-keyring = gnomeSource "libgnome-keyring" "2.32" "libgnome-keyring-2.32.0.tar.bz2" "sha256-VjiMDYHd/bV9MOSWPIPswcGEmKq5k5VCDg//aZKaDww=";
  libgnomecanvas = gnomeSource "libgnomecanvas" "2.30" "libgnomecanvas-2.30.3.tar.bz2" "sha256-hZt44ISJ/OTVwVxnb+wc15eC8RX1Fuiti+1qvLje3UA=";
  libgnomeui = gnomeSource "libgnomeui" "2.24" "libgnomeui-2.24.5.tar.bz2" "sha256-rjUvJJWInmVSTJeZMskJ9GKaWOZCkPsMlTMzcyJdPA8=";
  ORBit2 = gnomeSource "ORBit2" "2.14" "ORBit2-2.14.19.tar.bz2" "sha256-VckAqQVIKZJzD1dfPu801QvacXwZfJfAj6Wm6v2FdVA=";
  gnome-icon-theme = desktopSource "gnome-icon-theme-2.31.0.tar.bz2" "sha256-6n4Ft36tFZN5OSs7J1ygycus19k2AU5EfMfF4np2eYI=";
}
