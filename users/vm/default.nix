{ inputs
, pkgs
, lib
, config
, ...
}:
{
  imports = [ ../default.nix ]; 
  mainUser.name = "vm";
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; 
      cores = 8;         
    };
  };

  home-manager = {
    users.${config.mainUser.name} = import ./home.nix;
  };

  programs.zsh.enable = true;
  users.users.${config.mainUser.name} = {
    isNormalUser = true ;
    initialPassword = "test";
    description = config.mainUser.name;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
