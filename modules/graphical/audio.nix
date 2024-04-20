{config, lib,  pkgs, ...} :
with lib;
let
  cfg = config.custom.graphical.audio;
in
{
  options.custom.graphical.audio = {
    enable = mkEnableOption "Enables audio";
  };
  
  config = mkIf cfg.enable {
    # Enable sound with pipewire.
    sound.enable = false;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
  
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
