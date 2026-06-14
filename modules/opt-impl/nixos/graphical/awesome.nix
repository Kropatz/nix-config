{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.awesome;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager = {
        sddm.enable = true;
        defaultSession = "none+awesome";
      };

      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luarocks # is the package manager for Lua modules
          luadbi-mysql # Database abstraction layer
        ];

      };
    };
  };
}
