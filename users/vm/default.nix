{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../default.nix ];
  mainUser.name = "vm";
  mainUser.sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 kopatz";

  home-manager = {
    users.${config.mainUser.name} = import ./home.nix;
  };

  programs.zsh.enable = true;
  users.users.${config.mainUser.name} = {
    isNormalUser = true;
    initialPassword = "test";
    description = config.mainUser.name;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };
}
