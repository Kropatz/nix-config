{ lib, inputs, config, pkgsVersion, ... }:
with lib;
let cfg = config.custom.nix.settings;
in {
  options.custom.nix.settings = {
    enable = mkEnableOption "Enables various nix settings";
    optimise = mkOption {
      type = with types; bool;
      default = true;
      description = "Optimise nix store";
    };
  };

  config = mkIf cfg.enable {
    nix.optimise.automatic = cfg.optimise;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.registry.nixpkgs.flake = pkgsVersion;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nix.extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
    #nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nixpkgs.config.allowUnfree = true;
    ##home-manager.users.${config.mainUser.name}.home.sessionVariables = {
    ##  NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
    ##  NIXPKGS_ALLOW_UNFREE = "1";
    ##};
  };
}
