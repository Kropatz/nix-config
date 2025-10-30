{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./option.nix ];

  environment.systemPackages = [ pkgs.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [ config.mainUser.sshKey ];
  };
}
