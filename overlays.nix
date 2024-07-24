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
    hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;

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
