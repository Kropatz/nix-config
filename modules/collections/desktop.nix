{pkgs, config, ...}:
{
  imports = [
    ../cli-tools.nix
    ../docker.nix
    #../fh/scanning.nix
    ../flatpak.nix
    ../gpg.nix
    ../graphical/audio.nix
    ../graphical/code.nix
    ../graphical/emulators.nix
    ../graphical/gamemode.nix
    ../graphical/games.nix
    ../graphical/ime.nix
    ../graphical/obs.nix
    ../graphical/openrgb.nix
    ../graphical/plasma.nix
    ../graphical/shared.nix
    ../hardware/firmware.nix
    ../hardware/nvidia.nix
    ../hardware/ssd.nix
    ../kernel.nix # use latest kernel
    ../nftables.nix
    ../nix/index.nix
    ../nix/ld.nix
    ../nix/settings.nix
    ../noise-supression.nix
    ../services/syncthing.nix
    ../static-ip.nix
    ../support/ntfs.nix
    ../tmpfs.nix
    ../virt-manager.nix
    ../wireshark.nix
  ];

  kop.wooting.enable = true;
  #kop.tmpfs.enabled = true;
  #kop.wireshark.enabled = true;
  #kop.virt-manager.enabled = true;
}
