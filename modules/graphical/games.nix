{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.games;
  #proton-cachy = pkgs.proton-ge-bin.overrideAttrs (old: rec {
  #  pname = "proton-cachyos-bin";
  #  version = "cachyos-9.0-20250102-slr";
  #  src = pkgs.fetchzip {
  #    url =
  #      "https://github.com/CachyOS/proton-cachyos/releases/download/${version}/proton-${version}-x86_64_v3.tar.xz";
  #    hash = "sha256-aWpTUAm9FBuZI2KwEvhSnLB7Mfp5nYgUwvvLF47FIfM=";
  #  };
  #});
in
{
  options.custom.graphical.games = {
    enable = mkEnableOption "Enables games";
    enablePreinstalled = mkEnableOption "Enables preinstalled games";
    enableVr = mkEnableOption "Enables VR support";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        steamtinkerlaunch
      ];
    };
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };

    environment.systemPackages =
      with pkgs;
      [
        mangohud
        lutris
      ]
      ++ optionals cfg.enablePreinstalled (
        with pkgs;
        [
          #taisei
          osu-lazer-bin
          wineWowPackages.unstableFull
          winetricks
          heroic
          prismlauncher
          steamtinkerlaunch
          tetrio-desktop
          beyond-all-reason
          #libs
        ]
      )
      ++ optionals cfg.enableVr (with pkgs; [ bs-manager ]);

  };
}
