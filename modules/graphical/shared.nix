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
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

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
    enable = true;
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
    kate
    keepassxc
    jetbrains.idea-ultimate
    jetbrains.rider
    xfce.thunar
    insomnia
    remmina
    nextcloud-client
    thunderbird
    rofi
    taisei
    localsend
    element-desktop
    tetrioPlus
    krita
    unstable.libreoffice-fresh
    mangohud
    screenshot
    anki
    obs-studio
    mpv
    p7zip
    qbittorrent
    brightnessctl
    wacomtablet
    osu-lazer-bin
    libsForQt5.kolourpaint
    wl-clipboard
    yuzu-mainline
  ];

  #environment.sessionVariables = {
  #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  #};


}
