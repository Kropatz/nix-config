{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.sway;
in
{

  options = {
    custom.graphical.sway.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sway window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
    ];

    # enable sway window manager
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
