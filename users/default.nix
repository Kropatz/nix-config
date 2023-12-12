{ inputs
, pkgs
, lib
, config
, ...
}:
{
  imports = [ ./option.nix ]; 
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
  };
}
