{
  config,
  lib,
  ...
}:
{
  options.custom.graphical.hyprland = {
    enable = lib.mkEnableOption "Enables hyprland";
  };
  options.custom.graphical.hyprland.videobridge = {
    enable = lib.mkEnableOption "Enables xwaylandvideobridge for hyprland";
  };

}
