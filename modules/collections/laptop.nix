{ pkgs, config, ... }: {
  imports = [
    ../kernel.nix # use latest kernel
    ../services/wireguard-client.nix
  ];
  custom = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nix = {
      ld.enable = true;
      settings.enable = true;
    };
    misc = {
      podman.enable = true;
      firejail.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
      #tablet.enable = true;
      #fingerprint.enable = true;
    };
    graphical = {
      audio.enable = true;
      code = {
        enable = true;
        #android.enable = true;
      };
      #emulators.enable = true;
      gamemode.enable = true;
      gnome.enable = true;
      hyprland.enable = true;
      games.enable = true;
      ime.enable = true;
      shared.enable = true;
    };
  };
  programs.firejail.wrappedBinaries = with pkgs;
    let inherit (config.custom.misc.firejail) mk;
    in lib.mkMerge [
      (mk "Discord" { pkg = discord; })
    ];
}
