{lib,  inputs, config, pkgsVersion, ... }:
with lib;
let
  cfg = config.custom.nix.settings;
in
{
  options.custom.nix.settings = {
    enable = mkEnableOption "Enables various nix settings";
  };
  
  config = mkIf cfg.enable {
    nix.optimise.automatic = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.registry.nixpkgs.flake = pkgsVersion;
    nix.nixPath = ["nixpkgs=flake:nixpkgs"];
    home-manager.users.${config.mainUser.name}.home.sessionVariables = {
      NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}
