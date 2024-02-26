{ config, pkgs, inputs, lib, ... }:

let
  screenshot = pkgs.writeShellScriptBin "screenshot.sh" ''
    ${pkgs.scrot}/bin/scrot -fs - | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png -i
  '';
  tetrioPlus = pkgs.unstable.tetrio-desktop.overrideAttrs (old: {
      withTetrioPlus = true;
  });
in
{


  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    uw-ttyp0
    corefonts
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk 
  ];

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 53317 ]; #localsend
    allowedUDPPorts = [ 1194 53317 ]; #openvpn, localsend
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.xserver.wacom.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    keepassxc
    xfce.thunar
    remmina
    nextcloud-client
    thunderbird
    rofi
    localsend
    element-desktop
    tetrioPlus
    krita
    unstable.libreoffice-fresh
    mangohud
    screenshot
    anki
    mpv
    p7zip
    qbittorrent
    brightnessctl
    wacomtablet
    libsForQt5.kolourpaint
    wl-clipboard
  ];
}
