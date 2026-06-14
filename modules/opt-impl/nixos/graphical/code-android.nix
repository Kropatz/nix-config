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

  config = mkIf cfg.enable {
    documentation.dev.enable = true;
    environment.systemPackages = with pkgs; [
      #android-studio
      android-tools
    ];
    users.users.${config.mainUser.name}.extraGroups = [
      "adbusers"
      "kvm"
    ];
  };
}
