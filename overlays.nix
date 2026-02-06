# This file defines overlays
{ inputs, ... }:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
  neotestPatch = ''
     diff --git a/tests/unit/client/strategies/integrated_spec.lua b/tests/unit/client/strategies/integrated_spec.lua
    index 196c2e78..42a3df76 100644
    --- a/tests/unit/client/strategies/integrated_spec.lua
    +++ b/tests/unit/client/strategies/integrated_spec.lua
    @@ -34,7 +34,7 @@ describe("integrated strategy", function()

       a.it("stops the job", function()
         local process = strategy({
    -      command = { "bash", "-c", "sleep 1" },
    +      command = { "bash", "-c", "sleep 10" },
           strategy = {
             height = 10,
             width = 10,
    @@ -47,7 +47,7 @@ describe("integrated strategy", function()

       a.it("streams output", function()
         local process = strategy({
    -      command = { "bash", "-c", "printf hello; sleep 0; printf world" },
    +      command = { "bash", "-c", "printf hello; sleep 0.1; printf world" },
           strategy = {
             height = 10,
             width = 10,
  '';
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    vencord = prev.vencord.overrideAttrs {
      version = "1.14.1";
      src = prev.fetchFromGitHub {
        owner = "Vendicated";
        repo = "Vencord";
        tag = "v1.14.1";
        hash = "sha256-g+zyq4KvLhn1aeziTwh3xSYvzzB8FwoxxR13mbivyh4=";
      };
    };
    discord-canary = prev.discord-canary.override { withVencord = true; };
    discord = prev.discord.override { withVencord = true; };
    #tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    #xrdp = (import inputs.nixpkgs-working-xrdp {
    #  system = "x86_64-linux";
    #  config.allowUnfree = true;
    #}).xrdp;

    #jetbrains = prev.jetbrains // {
    #  jdk = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk;
    #  jdk-no-jcef = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef;
    #  jdk-no-jcef-17 = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef-17;
    #};

    hyprshade = prev.hyprshade.overrideAttrs {
      version = "4.0.0";
      src = prev.fetchFromGitHub {
        owner = "loqusion";
        repo = "hyprshade";
        tag = "4.0.0";
        hash = "sha256-NnKhIgDAOKOdEqgHzgLq1MSHG3FDT2AVXJZ53Ozzioc=";
      };
    };
    monado = prev.monado.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [
        "-DBUILD_WITH_OPENCV=OFF"
        (prev.lib.cmakeBool "XRT_HAVE_OPENCV" false)
      ];
    });

    luajitPackages = prev.luajitPackages // {
      neotest = prev.luajitPackages.neotest.overrideAttrs {
        patches = [ (prev.writeText "neotest-patch" neotestPatch) ];
      };
    };

    #hyprland = prev.hyprland.override {
    #  debug = true;
    #};
    #hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    #xdg-desktop-portal-hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    # to add input capture protocol support (needed for kde connect)
    #hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
    #  src = prev.fetchFromGitHub {
    #    owner = "3l0w";
    #    repo = "Hyprland";
    #    rev = "2464bfc318f83c093784561c6a0afca6871e119e";
    #    hash = "sha256-6MIA9wu9YW/eKsI0UEuP7CgDiribEv9apzr66dHzRME=";
    #    fetchSubmodules = true;
    #  };
    #});
    #hyprland-protocols = prev.hyprland-protocols.overrideAttrs (oldAttrs: {
    #  src = prev.fetchFromGitHub {
    #    owner = "3l0w";
    #    repo = "hyprland-protocols";
    #    rev = "d6bfa25be7b250dc417cbad89f13291efb0375d5";
    #    hash = "sha256-ULzGRSj18xOrTXnvWrkaaHUaMHaJWyXlmLDDw2jruLo=";
    #  };
    #});
    #xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (oldAttrs: {
    #  src = prev.fetchFromGitHub {
    #    #owner = "3l0w";
    #    #repo = "xdg-desktop-portal-hyprland";
    #    #rev = "436619a06641d7090e36416546d26b9aee2f0679";
    #    #hash = "sha256-OMv/8J2n2skwfVYFe1rY8pheL4T6rbWOTYYx/2u7ouk=";

    #    owner = "toneengo";
    #    repo = "xdg-desktop-portal-hyprland";
    #    rev = "f74a2278f78a5ec9167c945a40486d8999fefb9d";
    #    hash = "sha256-dH+NhC2Zz8v6MoTMaEK8qEZhHBpdCSI4818styWUFew=";
    #  };

    #  patches = [ (prev.writeText "testing-patch" testing-patch) ];
    #  buildInputs = oldAttrs.buildInputs ++ [ prev.libei ];
    #});

    #csharp-ls = prev.csharp-ls-8;
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
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
