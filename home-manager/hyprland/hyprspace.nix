{ config, osConfig, pkgs, inputs, lib, ... }:
let cfg = osConfig.custom.graphical.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      plugins = [ pkgs.hyprlandPlugins.hyprspace ];
      settings = {
        bind = [
          "$mainMod, TAB, overview:toggle"
          "$mainMod SHIFT, TAB, overview:toggle, all"
        ];
        plugin = [{
          overview = {
            affectStrut = false;
            hideTopLayers = true;
            panelHeight = 250;
            showEmptyWorkspace = false;
            showNewWorkspace = true;
            disableBlur = true;
          };
        }];
      };
    };
  };

}
