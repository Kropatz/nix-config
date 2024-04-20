{ config, pkgs, lib, inputs, ... }:
{
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = { ip = "127.0.0.1"; };
    environment.systemPackages = with pkgs; [
        docker-compose
    ];
    virtualisation.docker.enableNvidia = lib.mkIf config.custom.hardware.nvidia.enable true;
}
