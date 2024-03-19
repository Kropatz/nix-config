{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
#  programs.nix-ld.libraries = with pkgs; [
#    nspr
#    xorg.libXrandr
#    xorg.libX11
#    xorg.libXcomposite
#    xorg.libXdamage
#    xorg.libXfixes
#    xorg.libXrender
#    xorg.libXtst
#    xorg.libXau
#    xorg.libXdmcp
#    expat
#    libgcc.lib
#    libglvnd
#    zlib
#    zstd
#    stdenv.cc.cc
#    curl
#    openssl
#    attr
#    libssh
#    bzip2
#    libxml2
#    acl
#    libsodium
#    util-linux
#    xz
#    systemd
#    libkrb5
#    glib
#    nss
#    freetype
#    fontconfig.lib
#    dbus.lib
#    alsa-lib
#  ];
}
