{ config, pkgs, lib, inputs, ... }:
{
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
        docker-compose
    ];
}