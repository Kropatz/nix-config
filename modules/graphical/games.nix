{ pkgs, ...}:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };
  environment.systemPackages = with pkgs; [
    taisei
    tetrio
    osu-lazer-bin
    wineWowPackages.unstableFull
    winetricks
    lutris
    mangohud
    prismlauncher
    #libs
  ];
}
