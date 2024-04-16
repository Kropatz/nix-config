{config, lib,  pkgs, ... }:
with lib;
let
  cfg = config.kop.nix.ld;
in
{
  options.kop.nix.ld = {
    enable = mkEnableOption "Enables nix ld";
  };
  
  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      acl
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      attr
      bzip2
      cairo
      cups
      curl
      dbus.lib
      expat
      fontconfig.lib
      freetype
      gdk-pixbuf
      glib
      gtk3
      icu
      libGL
      libappindicator-gtk3
      libdrm
      libgcc.lib
      libglvnd
      libkrb5
      libnotify
      libpulseaudio
      libsodium
      libssh
      libusb1
      libuuid
      libxkbcommon
      libxml2
      mesa
      nspr
      nspr
      nss
      openssl
      pango
      pipewire
      stdenv.cc.cc
      systemd
      util-linux
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXau
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXdmcp
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
      xz
      zlib
      zstd
    ];
  };
}
