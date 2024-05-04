{pkgs, config, ...}:
{
  imports = [
    #../fh/scanning.nix
    ../flatpak.nix
    ../gpg.nix
    ../kernel.nix # use latest kernel
    ../services/syncthing.nix
    ../support/ntfs.nix
  ];

  custom = {
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    static-ip = {
      enable = true;
      interface = "enp42s0";
      ip = "192.168.0.11";
      dns = "192.168.0.6";
    };
    misc = {
      docker.enable = true;
    };
    hardware = {
      vfio.enable = true;
      nvidia.enable = true;
      firmware.enable = true;
      ssd.enable = true;
      wooting.enable = true;
    };
    graphical = {
      hyprland.enable = true;
      hyprland.videobridge.enable = true;
      audio.enable = true;
      code.enable = true;
      emulators.enable = true;
      gamemode.enable = true;
      games.enable = true;
      ime.enable = true;
      noise-supression.enable = true;
      obs.enable = true;
      openrgb.enable = true;
      plasma.enable = true;
      shared.enable = true;
    };
  };
}
