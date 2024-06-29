{ config, pkgs, inputs, lib, ... }:
with lib;
let
  cfg = config.custom.graphical.cosmic;
in
{
  options.custom.graphical.cosmic = {
    enable = mkEnableOption "Enables cosmic";
  };
  
  config = mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}

