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
    lact = prev.rdna4-lact;
    vencord = prev.vencord.overrideAttrs {
      version = "1.12.2";
      src = prev.fetchFromGitHub {
        owner = "Vendicated";
        repo = "Vencord";
        rev = "v1.12.2";
        hash = "sha256-a4lbeuXEHDMDko8wte7jUdJ0yUcjfq3UPQAuSiz1UQU=";
      };
    };
    xrdp = (import inputs.nixpkgs-working-xrdp {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }).xrdp;

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
