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
  gnome-applets = desktopSource "gnome-applets-2.32.0.tar.bz2" "sha256-OyYRsyU+1UGPN8g9cQkY6TR2p4NjfdtO9+Xqt6g6TBs=";
  gnome-desktop = desktopSource "gnome-desktop-2.32.0.tar.bz2" "sha256-ZtenjmEtmmV47N/aeqjBgMx2wDKgNN+E90KUSiCQPiU=";
  gnome-utils = desktopSource "gnome-utils-2.32.0.tar.bz2" "sha256-AzpVz0QglrKOpikgQzVP6v4ADR5fTruWKpttcuuak/o=";
  gnome-menus = desktopSource "gnome-menus-2.30.4.tar.bz2" "sha256-MXl9c8k+xPMILYRHxsK23CkAnEpPOscHWZnDh9xLDJ4=";
  gnome-panel = desktopSource "gnome-panel-2.32.0.2.tar.bz2" "sha256-BWP+szzqLgVa6DcJruNnOXikvqShDvTQXgCvF4Zwkjg=";
  gnome-session = desktopSource "gnome-session-2.32.0.tar.bz2" "sha256-S3V1dDAwYsulYM/+ymVOzNTtDdFj7+eTpKPvtoIt6iU=";
  gnome-settings-daemon = desktopSource "gnome-settings-daemon-2.32.0.tar.bz2" "sha256-1esCcAKPBy6NNsYeRnfVWERmnZqwnVJfbHa0mA7IHJ4=";
  gnome-mime-data = gnomeSource "gnome-mime-data" "2.18" "gnome-mime-data-2.18.0.tar.bz2" "sha256-NxlrWzcIW7zUXDOMNuJomP413Vl1KV9p9IAosehDb9c=";
  gnome-vfs = gnomeSource "gnome-vfs" "2.24" "gnome-vfs-2.24.4.tar.bz2" "sha256-Yt5ktbgE6wQQT/mPzWqLcnbVEKSfvZwP61aPiZZET6o=";
  gtkmm2 = gnomeSource "gtkmm" "2.24" "gtkmm-2.24.5.tar.xz" "sha256-BoClO3v5C05L9ETR2J5t9Bx3fgusyW6cCfxN0vX+a3I=";
  libIDL = gnomeSource "libIDL" "0.8" "libIDL-0.8.14.tar.bz2" "sha256-xdJNjAllRjU/vHzt8gg5LVoCr+nVbrzBzMsljXxNIiA=";
  libart_lgpl = gnomeSource "libart_lgpl" "2.3" "libart_lgpl-2.3.21.tar.bz2" "sha256-/cEedMEPyf/kGIU34rNwwKusyn2JAh1NMDr99/10dvo=";
  libbonobo = gnomeSource "libbonobo" "2.32" "libbonobo-2.32.0.tar.bz2" "sha256-uLgDfV6ON/OTlaKi+6fy+z1bU+ztw9QZGBkSuDGrE0k=";
  libbonoboui = gnomeSource "libbonoboui" "2.24" "libbonoboui-2.24.5.tar.bz2" "sha256-+rXyrGyELZSYYcB8tSCv5b7j3OVYBRUc6c0Bvg7Eb80=";
  libglade = gnomeSource "libglade" "2.6" "libglade-2.6.4.tar.bz2" "sha256-ZDYedkeDnTbtgzbZkv0hDT6BOYgiab7UfcRnSYAWXew=";
  libgnome = gnomeSource "libgnome" "2.32" "libgnome-2.32.0.tar.bz2" "sha256-1l5JvwdesrPv6+w4zrQJaTFU0YOWNldl2hpxYwvD3QI=";
  libgnome-keyring = gnomeSource "libgnome-keyring" "2.32" "libgnome-keyring-2.32.0.tar.bz2" "sha256-VjiMDYHd/bV9MOSWPIPswcGEmKq5k5VCDg//aZKaDww=";
  libgnomekbd = desktopSource "libgnomekbd-2.32.0.tar.bz2" "sha256-3dUsTMfYOtfvlkoby024dAfmWwD/w+cMCIyk7nOD0lY=";
  libgnomecanvas = gnomeSource "libgnomecanvas" "2.30" "libgnomecanvas-2.30.3.tar.bz2" "sha256-hZt44ISJ/OTVwVxnb+wc15eC8RX1Fuiti+1qvLje3UA=";
  libgweather = desktopSource "libgweather-2.30.3.tar.bz2" "sha256-uDU3RmFCPzfEaqjjc2iuJKaIVvEXt8IeR1oh79ulJkw=";
  libgnomeui = gnomeSource "libgnomeui" "2.24" "libgnomeui-2.24.5.tar.bz2" "sha256-rjUvJJWInmVSTJeZMskJ9GKaWOZCkPsMlTMzcyJdPA8=";
  libsoup = desktopSource "libsoup-2.32.0.tar.bz2" "sha256-CM8u0jVxd7l2OZSgLPT+6rQbrGG3clLX7oCQ4zcsnMk=";
  libunique = gnomeSource "libunique" "1.1" "libunique-1.1.6.tar.bz2" "sha256-5cgEHO+OM8VXMvBqKSOByzRduUbPeSpK4YqlxmzdT7s=";
  libwnck = desktopSource "libwnck-2.30.5.tar.bz2" "sha256-VrZoHonNRUkbtkAWXWInbYE2mgiXQEKyZkXcHg6VTME=";
  metacity = desktopSource "metacity-2.30.3.tar.bz2" "sha256-CPiHAY+l5EfPGE0DuuP+LAX9t1g77Wdo47TWY5L8GN0=";
  nautilus = desktopSource "nautilus-2.32.0.tar.bz2" "sha256-B5y0vIxa/AEqzFSxf5G3Zz3NPjkWIkEpsVqB6rVT8ZI=";
  ORBit2 = gnomeSource "ORBit2" "2.14" "ORBit2-2.14.19.tar.bz2" "sha256-VckAqQVIKZJzD1dfPu801QvacXwZfJfAj6Wm6v2FdVA=";
  gnome-icon-theme = desktopSource "gnome-icon-theme-2.31.0.tar.bz2" "sha256-6n4Ft36tFZN5OSs7J1ygycus19k2AU5EfMfF4np2eYI=";
  gnome-control-center = desktopSource "gnome-control-center-2.32.0.tar.bz2" "sha256-17CefgczPai0aKGyr3pkzRLhvyvVDFfiwA5MMGQvEC8=";
  gtk-engines = desktopSource "gtk-engines-2.20.1.tar.bz2" "sha256-xQLuR3jhqOIy9DD7V1FGoIgCZkcdGdvXjuUeqnadphQ=";
  gnome-terminal = desktopSource "gnome-terminal-2.32.0.tar.bz2" "sha256-Pp+SK+pK9/AWtm8yBCZsiZNYLFGhL2z9zkdgcgJAByU=";
  gnome-themes = desktopSource "gnome-themes-2.32.0.tar.bz2" "sha256-gtvNPiwxfbi3Pr2Bp6foTnZNcjULUanfHX3dfWXR+xs=";
  vte = desktopSource "vte-0.26.0.tar.bz2" "sha256-Cx6co3f4CRLZ+5osLYdsj934sLf+C9Fp2AZxr+b0fk0=";
  gnome-keyring = desktopSource "gnome-keyring-2.32.0.tar.bz2" "sha256-1A+DZnrBea5bgQLQftceTTn8h+JxhFw5kqTNejJoZKo=";
  gtksourceview = desktopSource "gtksourceview-2.10.5.tar.bz2" "sha256-xYV3N0Ox34oEsb5/fZDuzfImgUkNaBC+VMgaeuFSGR4=";
  gucharmap = desktopSource "gucharmap-2.32.0.tar.bz2" "sha256-sHnZwDM4JjiOwYfzxJQaObjQT4HMksVyqTv0ZJBfvNk=";
  libgnomeprint = desktopSource "libgnomeprint-2.18.8.tar.bz2" "sha256-EDTshlEFH4TSQk56HaYcUwQizCDOWy2eEH4eRneNlpE=";
  libgnomeprintui = desktopSource "libgnomeprintui-2.18.6.tar.bz2" "sha256-FWrltm5dzFRu+iRJBI95LXbFWzDZOptnsMaWZeNG9Go=";
  libgtop = desktopSource "libgtop-2.28.2.tar.bz2" "sha256-SZWNfaH3ayV7/Q1VfY7Sshilqw0xtZ/tHDLd8qFSn10=";
  at-spi2-core = desktopSource "at-spi2-core-0.4.0.tar.bz2" "sha256-pXm2KMyMYDbDpX2r7Yniv/th3xrwEb3a5otdOpJ5pmw=";
  at-spi2-atk = desktopSource "at-spi2-atk-0.4.0.tar.bz2" "sha256-LiMIzWf+JW4ICF5JmAj25BuNSWfZGDH/fyWVOJj8W0Y=";
  libgail-gnome = desktopSource "libgail-gnome-1.20.3.tar.bz2" "sha256-lB9HzqrrtQj2YkdjkFHSMyhNk/P0KnYoSp+NHAugmiI=";
  gstreamer = desktopSource "gstreamer-0.10.30.tar.bz2" "sha256-6O8wG+QjeX/zaguzYVkwsRK0F1Y0BR0Z/WVeDtl0Uyo=";
  gst-plugins-base = desktopSource "gst-plugins-base-0.10.30.tar.bz2" "sha256-Y5OGQTgL6ZNcgEro1VrNz9k5IO0t63Lc9w8Ceniwhdc=";
  gst-plugins-good = desktopSource "gst-plugins-good-0.10.25.tar.bz2" "sha256-tdV1DBJBLEfYW6k5HIQvbwLK2VEYdmleSLFfs35GmfY=";
  gvfs = desktopSource "gvfs-1.6.4.tar.bz2" "sha256-4eKBBni0LLAWBkLwzTPM03fN37GPyGjW+qBMRJ+BNpM=";
  alacarte = desktopSource "alacarte-0.13.2.tar.bz2" "sha256-n6NuUYGx7qlHsYTLD3nXlrJcxaXxIoGaGsL/Abx+5O0=";
  bug-buddy = desktopSource "bug-buddy-2.32.0.tar.bz2" "sha256-/9xw/kpZwK70K1sLcrCPF9srHZ9JuitociM03b7l48o=";
  dasher = desktopSource "dasher-4.11.tar.bz2" "sha256-+yHMTvYG4QqOXe/+voaVo3bquwdm19G9+Aq8XwP0/tI=";
  gcalctool = desktopSource "gcalctool-5.32.0.tar.bz2" "sha256-dMPInHmKa9aGs409BugRmMU30EwKF3ETD405nVI0tGM=";
  gconf-editor = desktopSource "gconf-editor-2.32.0.tar.bz2" "sha256-xtHTXOXRNhIa127+HEAzQluyrTgA5xG9G8qc6GnBKh8=";
  gnome-netstatus = desktopSource "gnome-netstatus-2.28.2.tar.bz2" "sha256-0a0KZooTRImNT0e1WRrd3HeR7bbC6SE268+NJ42VkRk=";
  gnome-nettool = desktopSource "gnome-nettool-2.32.0.tar.bz2" "sha256-jHD4WVJ2AXARSy+kvjzKo/ximPgCus2iUD7UgrigU5w=";
  gok = desktopSource "gok-2.30.1.tar.bz2" "sha256-ZCLe24DCyz1e5HI4Inlg3A5t3g0NE1HMfRHeBgicNsA=";
  mousetweaks = desktopSource "mousetweaks-2.32.0.tar.bz2" "sha256-h05m3Af1+gp6MqMq5WuzR+71hD11yUpjy0rTlC+bUEc=";
  zenity = desktopSource "zenity-2.32.0.tar.bz2" "sha256-kXUWdqAZQuxEV4YiXlzMHEug7TDTO4sXfhzbAUtOOu8=";
  eog = desktopSource "eog-2.32.0.tar.bz2" "sha256-cKTrdTrPRFuj8Hv1nRzK1nmxxApzxW8CxN9RZeM2wto=";
  evince = desktopSource "evince-2.32.0.tar.bz2" "sha256-KkyRrjj4tQKM67kbnandxQ6orj89Qp34m6NR2i14f/c=";
  file-roller = desktopSource "file-roller-2.32.0.tar.bz2" "sha256-m9EUYAMH7jEiYKEO67LwopeY3C81aaaM67X0VmZWOOc=";
  gedit = desktopSource "gedit-2.30.4.tar.bz2" "sha256-pWH+PdHRmbrt4b0HxO5l8G/HxJTdTTMnEX8EFJpgjjw=";
  gnome-system-monitor = desktopSource "gnome-system-monitor-2.28.2.tar.bz2" "sha256-tijt/TnjprN0zhM/Nn01aEdetOmBo2f0+dYql4Tlrlk=";
  seahorse = desktopSource "seahorse-2.32.0.tar.bz2" "sha256-9VRoI3JGpIUxfVni+8Gx719b1MWnuf9vQMPZIa8O1S0=";
  seahorse-plugins = desktopSource "seahorse-plugins-2.30.1.tar.bz2" "sha256-H9/tGu8sIqKamrwA6uZ3UoVORmpmzuKowcJ4J36DLWY=";
  totem-pl-parser = desktopSource "totem-pl-parser-2.32.0.tar.bz2" "sha256-LsQLyqHRpeU90MBRGsTVE5kIbXBwPUxbPpdfVkfB8e8=";
  nautilus-sendto = desktopSource "nautilus-sendto-2.32.0.tar.bz2" "sha256-iQCQskOB2R8HlhDVRUy3hqPs78kfoGZJsiIr6bsCJpo=";
  yelp = desktopSource "yelp-2.30.2.tar.bz2" "sha256-X4w1hHva5lTiHLumaGXWtYLZ/ICgWa0pCBu4fhRrsWU=";
  gnome-color-manager = desktopSource "gnome-color-manager-2.32.0.tar.bz2" "sha256-+ih+8S0ylkPR8BuPNcKxBN0pPNMOkaAS8EkpwgPaVM8=";
  gnome-bluetooth = desktopSource "gnome-bluetooth-2.32.0.tar.bz2" "sha256-V7HwbJahuF4cGf+RnXCMw46V7a5liIHtmZaMMlg5qXM=";
  gnome-user-share = desktopSource "gnome-user-share-2.30.1.tar.bz2" "sha256-MLoHQgpJVFD4C0vgAWARUEU93DUE/yPEhv0VQf9aG/4=";
  # Not GNOME-hosted: libcanberra is Lennart Poettering's own project.
  # Built locally with GTK2 support since nixpkgs' libcanberra in this
  # snapshot only wires up a GTK3 module.
  libcanberra = fetchurl {
    url = "http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz";
    hash = "sha256-wrZx5n4MKIpp/DPcG28bU00HiCwqzu03AEv0jGAa+nI=";
  };
}
