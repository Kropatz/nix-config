{ pkgs, inputs, ... }:
{
  imports = [ ./home-manager/nvim.nix ];
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
    users.anon = {
      home.stateVersion = "23.05";
    };
  };
  
  users.users.anon = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
    ];
  };
}
