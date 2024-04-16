{pkgs, config, ...}:
{
  imports = [
    ../graphical/hyprland.nix # TODO
  ];
  kop = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nix = {
      ld.enable = true;
      settings.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
    graphical = {
      audio.enable = true;
      code.enable = true;
      emulators.enable = true;
      gamemode.enable = true;
      games.enable = true;
      ime.enable = true;
      shared.enable = true;
    };
  };
}
