{ lib, inputs, config, pkgsVersion, ... }:
with lib;
let
  cfg = config.custom.nix.settings;
  cache = "https://cache.nixos.org";
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
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust =
      lib.mkDefault 250;

    nix = {
      optimise.automatic = cfg.optimise;
      settings.experimental-features = [ "nix-command" "flakes" ];
      settings.substituters =
        lib.mkIf (config.networking.hostName == "kop-pc")
        [ "http://192.168.0.20:5000" ];
      settings.trusted-public-keys =
        [ "amd-server:r5S7vv/3sZ0knhMvpUzRHXFlBHgov2tLhtoKqLXYf28=" ];
      registry.nixpkgs.flake = pkgsVersion;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      extraOptions = ''
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';
    };
    #nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
    nixpkgs.config.allowUnfree = true;
    ##home-manager.users.${config.mainUser.name}.home.sessionVariables = {
    ##  NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
    ##  NIXPKGS_ALLOW_UNFREE = "1";
    ##};
  };
}
