# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    #discord = prev.discord.override { withVencord = true; };
    #discord = prev.vesktop;
    tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    nerdfonts = prev.nerdfonts.override { fonts = [ "Hack" "Noto" ]; };
    waybar = prev.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });

    # .png doesnt work :(
    #fastfetch = prev.fastfetch.overrideAttrs (oldAttrs: {
    #  cmakeFlags = [ (prev.lib.cmakeBool "ENABLE_IMAGEMAGICK6" true) (prev.lib.cmakeBool "ENABLE_IMAGEMAGICK7" true) (prev.lib.cmakeBool "ENABLE_CHAFA" true)  ];
    #});
    trashy = prev.trashy.overrideAttrs rec {
      version = "unstable-2.0.0";
      src = prev.fetchFromGitHub {
        owner = "oberblastmeister";
        repo = "trashy";
        rev = "7c48827e55bca5a3188d3de44afda3028837b34b";
        sha256 = "1pxmeXUkgAITouO0mdW6DgZR6+ai2dax2S4hV9jcJLM=";
      };
      cargoDeps = prev.rustPlatform.fetchCargoTarball {
        inherit src;
        hash = "sha256-/q/ZCpKkwhnPh3MMVNYZw6XvjyQpoZDBXCPagliGr1M=";
      };
    };
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
