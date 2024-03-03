{ inputs, config, pkgsVersion, ... }:
{
  nix.optimise.automatic = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.registry.nixpkgs.flake = pkgsVersion;
  nix.nixPath = ["nixpkgs=flake:nixpkgs"];
  home-manager.users.${config.mainUser.name}.home.sessionVariables.NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
}
