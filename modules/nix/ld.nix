{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.nix.ld;
in
{
  options.custom.nix.ld = {
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
      libgbm
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
      libX11
      libXScrnSaver
      libXau
      libXcomposite
      libXcursor
      libXdamage
      libXdmcp
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libxcb
      libxkbfile
      libxshmfence
      libICE
      libSM
      xz
      zlib
      zstd
      # TriOS
      harfbuzz
      libepoxy
      # android
      libpng
      libbsd
    ];
  };
}
