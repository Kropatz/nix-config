{ config, pkgs, lib, ... }:
let cfg = config.custom.graphical.sddm;
in {

  options = {
    custom.graphical.sddm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sddm";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      displayManager.sddm = {
        enable = true;
        theme = "${pkgs.sddm-astronaut}";
        #wayland.enable = true;
        #sddm.theme = "breeze";
      };
    };
  };
}
