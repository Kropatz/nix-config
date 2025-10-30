{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.hardware.android;
in
{
  options.custom.hardware.android = {
    enable = lib.mkEnableOption "Enables android phone support";
  };

  config = lib.mkIf cfg.enable {
    programs.adb = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      scrcpy # mirrors screen to pc, -S turns off screen while active, --render-driver opengl uses opengl for rendering
    ];
    users.users.${config.mainUser.name}.extraGroups = [ "adbusers" ];
  };
}
