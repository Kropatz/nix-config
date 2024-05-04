{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.misc.docker;
in
{
  options.custom.misc.docker = {
    enable = mkEnableOption "Enables docker";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = { ip = "127.0.0.1"; };
    environment.systemPackages = with pkgs; [
        docker-compose
    ];
    virtualisation.docker.enableNvidia = lib.mkIf config.custom.hardware.nvidia.enable true;
  };
}
