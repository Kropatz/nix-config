{ pkgs, config, ... }:
{
  #xdg.configFile."openvr/openvrpaths.vrpath".text = ''
  #  {
  #    "config" :
  #    [
  #      "~/.local/share/Steam/config"
  #    ],
  #    "external_drivers" : null,
  #    "jsonid" : "vrpathreg",
  #    "log" :
  #    [
  #      "~/.local/share/Steam/logs"
  #    ],
  #    "runtime" :
  #    [
  #      "${pkgs.opencomposite}/lib/opencomposite"
  #    ],
  #    "version" : 1
  #  }
  #'';
}
