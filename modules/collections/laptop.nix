{ pkgs, config, ... }: {
  imports = [
    ../kernel.nix # use latest kernel
    ../services/wireguard-client.nix
    ../services/ssh.nix
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
    services = {
      syncthing.enable = true;
    };
    graphical = {
      audio.enable = true;
      basics.enable = true;
      code = {
        enable = true;
        #android.enable = true;
      };
      #emulators.enable = true;
      gnome.enable = true;
      hyprland.enable = true;
      #games.enable = true;
      ime.enable = true;
      shared.enable = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" "electron-28.3.3" ];
  programs.firejail.wrappedBinaries = with pkgs;
    let inherit (config.custom.misc.firejail) mk;
    in lib.mkMerge [
      (mk "Discord" { pkg = discord; })
    ];
}
