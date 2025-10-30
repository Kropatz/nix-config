{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.code.android;
in
{
  options.custom.graphical.code.android = {
    enable = mkEnableOption "Enables code";
  };

  config = mkIf cfg.enable {
    documentation.dev.enable = true;
    programs.adb.enable = true;
    environment.systemPackages = with pkgs; [ android-studio ];
    users.users.${config.mainUser.name}.extraGroups = [
      "adbusers"
      "kvm"
    ];
  };
}
