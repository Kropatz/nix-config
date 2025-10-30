{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.mpv = {
    enable = true;
    config = {
      volume = 50;
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      videoclip # keybind = c
      autoload
      #modernx
    ];
  };
}
