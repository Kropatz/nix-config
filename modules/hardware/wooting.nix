{ config, pkgs, lib, ...}:
with lib;
let 
  cfg = config.kop.hardware.wooting;
in
{ 
  options.kop.hardware.wooting = {
    enable = mkEnableOption "Enable wooting hardware support";
  };

  config = let
    wooting-udev = pkgs.stdenv.mkDerivation rec {
      pname = "wooting-udev-rules";
      version = "unstable-2023-03-31";

      # Source: https://help.wooting.io/en/article/wootility-configuring-device-access-for-wootility-under-linux-udev-rules-r6lb2o/
      src = [ ./wooting.rules ];

      dontUnpack = true;

      installPhase = ''
        install -Dpm644 $src $out/lib/udev/rules.d/70-wooting.rules
      '';

      meta = with lib; {
        homepage = "https://help.wooting.io/en/article/wootility-configuring-device-access-for-wootility-under-linux-udev-rules-r6lb2o/";
        description = "udev rules that give NixOS permission to communicate with Wooting keyboards";
        platforms = platforms.linux;
        license = "unknown";
        maintainers = with maintainers; [ davidtwco ];
      };
    };
  in mkIf cfg.enable {
    services.udev.packages = [ wooting-udev ];

    environment.systemPackages = with pkgs; [
      wootility
    ];
  };
}
