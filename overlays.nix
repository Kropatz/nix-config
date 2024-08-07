# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    discord = prev.discord.override { withVencord = true; };
    #discord = prev.vesktop;
    tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    nerdfonts = prev.nerdfonts.override { fonts = [ "Hack" "Noto" ]; };
    waybar = prev.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    egl-wayland = prev.egl-wayland.overrideAttrs (oldAttrs: {
      src = prev.fetchFromGitHub {
        owner = "Nvidia";
        repo = "egl-wayland";
        rev = "c439cd596fb7eadae69012eaba013c39b2377771";
        hash = "sha256-+J2BTxY9c1EUOwUzLxomROM2raRwVCKXE2xq0jsDgLE=";
      };
    });
    hyprland =
      inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    xdg-desktop-portal-hyprland =
      inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

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
}
