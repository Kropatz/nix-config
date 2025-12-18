{config, inputs, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
  };

}
