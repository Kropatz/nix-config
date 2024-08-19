{ config, pkgs, inputs, lib, ... }:
let
  cfg = config.custom.graphical.cosmic;
in
{
  options.custom.graphical.cosmic = {
    enable = lib.mkEnableOption "Enables cosmic";
  };
  
  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = if (config.custom.graphical.sddm.enable == false) then true else false;
  };
}

