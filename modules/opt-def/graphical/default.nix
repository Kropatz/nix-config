{
  pkgs,
  config,
  lib,
  ...
}:
{

  imports = [
    ./gpu-screen-recorder-ui.nix
  ];

  options.custom.graphical = {
    firefox-custom = {
      enable = lib.mkEnableOption "Enables custom firefox";
    };
    audio = {
      enable = lib.mkEnableOption "Enables audio";
    };
    awesome = {
      enable = lib.mkEnableOption "Enables awesome";
    };
    code = {
      enable = lib.mkEnableOption "Enables code";
      rider = lib.mkEnableOption "Enables Rider";
      clion = lib.mkEnableOption "Enables Clion";
      android = {
        enable = lib.mkEnableOption "Enables code";
      };
    };
    basics = {
      enable = lib.mkEnableOption "Enables basics";
    };
    cosmic = {
      enable = lib.mkEnableOption "Enables cosmic";
    };
    emulators = {
      enable = lib.mkEnableOption "Enables emulators";
    };
    games = {
      enable = lib.mkEnableOption "Enables games";
      enablePreinstalled = lib.mkEnableOption "Enables preinstalled games";
      enableVr = lib.mkEnableOption "Enables VR support";
    };
    gnome = {
      enable = lib.mkEnableOption "Enables gnome";
    };
    hyprland = {
      enable = lib.mkEnableOption "Enables hyprland";
      videobridge = {
        enable = lib.mkEnableOption "Enables xwaylandvideobridge for hyprland";
      };
    };
    i3.enable = lib.mkEnableOption "Enable i3 window manager";
    ime.enable = lib.mkEnableOption "Enables ime";
    lightdm.enable = lib.mkEnableOption "Enables lightdm";
    lxqt.enable = lib.mkEnableOption "Enables lxqt";
    nightlight.enable = lib.mkEnableOption "Enables nightlight";
    niri.enable = lib.mkEnableOption "Enables niri";
    noise-supression.enable = lib.mkEnableOption "Enables noise-supression";
    obs.enable = lib.mkEnableOption "Enables obs";
    openrgb.enable = lib.mkEnableOption "Enables openrgb";
    plasma.enable = lib.mkEnableOption "Enables plasma";
    qylock.enable = lib.mkEnableOption "Enables qylock";
    sddm.enable = lib.mkEnableOption "Enables sddm";
    shared.enable = lib.mkEnableOption "Enables shared";
    sway.enable = lib.mkEnableOption "Enables sway";
    tuigreet.enable = lib.mkEnableOption "Enables tuigreet";
    wayvnc.enable = lib.mkEnableOption "Enables wayvnc";
    xfce.enable = lib.mkEnableOption "Enables xfce";
  };
}
