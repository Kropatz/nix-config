{ config, pkgs, lib, vars, ... }:
let
  wm = vars.wm;
in
{
    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = wm;
    services.xrdp.openFirewall = true;
}
