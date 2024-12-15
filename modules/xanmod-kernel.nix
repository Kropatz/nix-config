{ pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelModules = [ "ntsync" ];
}
