{ config, pkgs, lib, ... }:
let cfg = config.custom.graphical.niri;
in {

  options = {
    custom.graphical.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable niri";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = { enable = true; };
    environment.systemPackages = with pkgs; [ xwayland-satellite ];
  };
}
