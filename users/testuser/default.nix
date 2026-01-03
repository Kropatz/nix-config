{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../default.nix ];

  programs.zsh.enable = true;
  users.users.testuser = {
    isNormalUser = true;
    initialPassword = "1";
    description = "Test user";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ config.mainUser.sshKey ];
  };
}
