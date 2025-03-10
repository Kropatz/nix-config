# This file defines overlays
{ inputs, ... }:
let
  addPatches = pkg: patches:
    pkg.overrideAttrs
    (oldAttrs: { patches = (oldAttrs.patches or [ ]) ++ patches; });
in {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    discord-canary = prev.discord-canary.override { withVencord = true; };
    discord = prev.discord.override { withVencord = true; };
    tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    #hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
    #  version = "0.45.0";
    #  src = prev.fetchFromGitHub {
    #    owner = "hyprwm";
    #    repo = "hyprland";
    #    fetchSubmodules = true;
    #    rev = "refs/tags/v0.45.0";
    #    hash = "sha256-//Ib7gXCA8jq8c+QGTTIO0oH0rUYYBXGp8sqpI1jlhA=";
    #  };
    #});

    #  mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    #});
    #hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    #xdg-desktop-portal-hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    #delta = prev.delta.overrideAttrs (oldAttrs: rec {
    #  version = "0.17.0-unstable-2024-08-12";
    #  src = prev.fetchFromGitHub {
    #    owner = "dandavison";
    #    repo = "delta";
    #    rev = "a01141b72001f4c630d77cf5274267d7638851e4";
    #    hash = "sha256-My51pQw5a2Y2VTu39MmnjGfmCavg8pFqOmOntUildS0=";
    #  };
    #  cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
    #    inherit src;
    #    outputHash = "sha256-TJ/yLt53hKElylycUfGV8JGt7GzqSnIO3ImhZvhVQu0=";
    #  };
    #});

    # .png doesnt work :(
    #fastfetch = prev.fastfetch.overrideAttrs (oldAttrs: {
    #  cmakeFlags = [ (prev.lib.cmakeBool "ENABLE_IMAGEMAGICK6" true) (prev.lib.cmakeBool "ENABLE_IMAGEMAGICK7" true) (prev.lib.cmakeBool "ENABLE_CHAFA" true)  ];
    #});
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "electron-27.3.11" ];
    };
  };
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  gimp3 = final: _prev: {
    gimp3 = import inputs.nixpkgs-gimp3 {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
