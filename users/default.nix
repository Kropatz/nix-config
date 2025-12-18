{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./option.nix ];

  users.users.root = {
    openssh.authorizedKeys.keys = [ config.mainUser.sshKey ];
  };
}
