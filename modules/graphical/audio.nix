{config, lib,  pkgs, ...} :
with lib;
let
  cfg = config.kop.graphical.audio;
in
{
  options.kop.graphical.audio = {
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
    };
  };
}
