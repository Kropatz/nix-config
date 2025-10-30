{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  interface = vars.interface;
in
{
  networking.interfaces.${interface}.wakeOnLan.enable = true;
}
