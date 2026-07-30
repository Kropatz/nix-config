{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom;
in
{
  imports = [
    ./backup.nix
    ./cli-tools.nix
    ./packages-list.nix
    ./podman.nix
    ./static-ip.nix
    ./virt-manager.nix
    ./hardening.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.misc.btrfs.enable {
      services.btrfs.autoScrub.enable = true;
    })
    (lib.mkIf cfg.misc.docker.enable {
      virtualisation.docker.enable = true;
      virtualisation.docker.daemon.settings = {
        ip = "127.0.0.1";
      };
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
      hardware.nvidia-container-toolkit.enable = lib.mkIf config.custom.hardware.nvidia.enable true;
    })
    (lib.mkIf cfg.misc.fasterboot.enable {
      # before: Startup finished in 18.830s (firmware) + 5.844s (loader) + 4.422s (kernel) + 7.616s (userspace) = 36.713s
      # after: Startup finished in 14.115s (firmware) + 789ms (loader) + 4.312s (kernel) + 5.777s (userspace) = 24.995s
      systemd = {
        targets.network-online.wantedBy = lib.mkForce [ ]; # Normally ["multi-user.target"]
        services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ]; # Normally ["network-online.target"]
      };
      # mash spacebar to still be able to select a different boot option
      boot.loader.timeout = lib.mkDefault 1;

      virtualisation.docker.enableOnBoot = false;
    })
    (lib.mkIf cfg.misc.firejail.enable {
      programs.firejail.enable = true;
    })
    (lib.mkIf cfg.misc.newkernel.enable {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })
    (lib.mkIf cfg.misc.zram.enable {
      zramSwap = {
        enable = true;
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.page-cluster" = 0;
        #"vm.watermark_boost_factor" = 0;
        #"vm.watermark_scale_factor" = 125;
      };
    })
    (lib.mkIf cfg.nftables.enable {
      networking.nftables.enable = true;
    })
    (lib.mkIf cfg.tmpfs.enable {
      boot.tmp.useTmpfs = true;
    })
    (lib.mkIf cfg.wireshark.enable {
      programs.wireshark.enable = true;
      programs.wireshark.package = pkgs.wireshark;

      users.users.${config.mainUser.name}.extraGroups = [ "wireshark" ];
    })
  ];
}
