{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../modules/services/ssh.nix
  ];

  time.timeZone = "Europe/Vienna";
  custom = {
    nftables.enable = true;
    nix = {
      ld.enable = true;
      settings.enable = true;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2"
  ];
  environment.systemPackages = map lib.lowPrio [ pkgs.curl pkgs.gitMinimal ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  system.stateVersion = "24.05";
}
