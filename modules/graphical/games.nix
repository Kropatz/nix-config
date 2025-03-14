{ config, lib, pkgs, ... }:
with lib;
let cfg = config.custom.graphical.games;
in {
  options.custom.graphical.games = {
    enable = mkEnableOption "Enables games";
    enablePreinstalled = mkEnableOption "Enables preinstalled games";
    enableVr = mkEnableOption "Enables VR support";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin steamtinkerlaunch ];
    };
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-runtime-wrapped-7.0.20"
      "dotnet-runtime-wrapped-7.0.20"
      "dotnet-runtime-wrapped-7.0.20"
    ];
    environment.systemPackages = [ pkgs.mangohud ]
      ++ optionals cfg.enablePreinstalled (with pkgs; [
        #taisei
        #osu-lazer-bin
        wineWowPackages.unstableFull
        winetricks
        lutris
        prismlauncher
        steamtinkerlaunch
        tetrio-desktop
        #libs
      ]) ++ optionals cfg.enableVr (with pkgs; [ beatsabermodmanager ]);

  };
}
