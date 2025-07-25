# This file defines overlays
{ inputs, ... }:
let
  addPatches = pkg: patches:
    pkg.overrideAttrs
      (oldAttrs: { patches = (oldAttrs.patches or [ ]) ++ patches; });
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    discord-canary = prev.discord-canary.override { withVencord = true; };
    discord = prev.discord.override { withVencord = true; };
    tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    xrdp = (import inputs.nixpkgs-working-xrdp {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }).xrdp;

    jetbrains = prev.jetbrains // {
      jdk = (import inputs.nixpkgs-working-jetbrains {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).jetbrains.jdk;
      jdk-no-jcef = (import inputs.nixpkgs-working-jetbrains {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).jetbrains.jdk-no-jcef;
      jdk-no-jcef-17 = (import inputs.nixpkgs-working-jetbrains {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }).jetbrains.jdk-no-jcef-17;
    };

    hyprshade = prev.hyprshade.overrideAttrs {
      version = "4.0.0";
      src = prev.fetchFromGitHub {
        owner = "loqusion";
        repo = "hyprshade";
        tag = "4.0.0";
        hash = "sha256-NnKhIgDAOKOdEqgHzgLq1MSHG3FDT2AVXJZ53Ozzioc=";
      };
    };

    #hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    #xdg-desktop-portal-hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    csharp-ls = prev.csharp-ls-8;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  #unstable-packages = final: _prev: {
  #  unstable = import inputs.nixpkgs-unstable {
  #    system = final.system;
  #    config.allowUnfree = true;
  #    config.permittedInsecurePackages = [ "electron-27.3.11" ];
  #  };
  #};
  #stable-packages = final: _prev: {
  #  stable = import inputs.nixpkgs {
  #    system = final.system;
  #    config.allowUnfree = true;
  #  };
  #};
}
