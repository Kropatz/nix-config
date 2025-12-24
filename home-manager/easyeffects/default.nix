{ pkgs, config, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "mic";
    extraPresets = {
      mic = builtins.fromJSON (builtins.readFile ./mic.json);
      other_mic = builtins.fromJSON (builtins.readFile ./other_mic.json);
    };
  };
}
