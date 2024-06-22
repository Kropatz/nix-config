{ config, pkgs, lib, ... }:
let cfg = config.custom.hardware.android;
in {
  options.custom.hardware.android = {
    enable = lib.mkEnableOption "Enables android phone support";
  };

  config = lib.mkIf cfg.enable {
    programs.adb = {
      enable = true;
    };
    users.users.${config.mainUser.name}.extraGroups = [ "adbusers" ];
  };
}
