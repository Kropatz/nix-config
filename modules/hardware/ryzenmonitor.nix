{ config, pkgs, ... }: {

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
    kernelModules = [ "zenpower" ];
    blacklistedKernelModules = [ "k10temp" ];
  };
  environment.systemPackages = with pkgs; [ zenmonitor ];
}
