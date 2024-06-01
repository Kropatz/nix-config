{
  description = "Kop's NixOS Flake";
  inputs = {
    # secrets management
    agenix.url = "github:ryantm/agenix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    nur = { url = "github:nix-community/NUR"; };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix.url = "github:danth/stylix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nur, nixpkgs, nixos-hardware, nixos-wsl, nixpkgs-unstable
    , agenix, home-manager, home-manager-unstable, nix-colors, nixos-cosmic
    , nixvim, stylix, disko, flake-utils }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      # helper function to create a machine
      mkHost = { modules, specialArgs ? { pkgsVersion = nixpkgs-unstable; }
        , system ? "x86_64-linux", minimal ? false, stylixEnabled ? false }:
        specialArgs.pkgsVersion.lib.nixosSystem {
          inherit system;
          modules = modules ++ [
            ./modules
            agenix.nixosModules.default
            ({ outputs, ... }: {
              nixpkgs.overlays = with outputs.overlays; [
                additions
                modifications
                unstable-packages
                stable-packages
                nur.overlay
              ];
            })
          ] ++ (if !minimal then [
            home-manager-unstable.nixosModules.home-manager
            nixos-cosmic.nixosModules.default
            ./modules/graphical/cosmic.nix
          ] else
            [ ]) ++ (if stylixEnabled then [
              stylix.nixosModules.stylix
              ./modules/graphical/stylix.nix
            ] else
              [ ]);
          specialArgs = specialArgs // { inherit inputs outputs; };
        };
    in flake-utils.lib.eachDefaultSystem (system: {
      packages =
        import ./pkgs { pkgs = nixpkgs-unstable.legacyPackages.${system}; };
    }) // {

      overlays = import ./overlays.nix { inherit inputs; };

      nixosConfigurations = {
        server = mkHost {
          modules = [
            ./users/anon
            ./modules/collections/server.nix
            ./systems/server/configuration.nix
          ];
          specialArgs = {
            ## Custom variables (e.g. ip, interface, etc)
            vars = import ./systems/userdata-default.nix
              // import ./systems/server/userdata.nix;
            pkgsVersion = nixpkgs;
          };
        };
        "kop-pc" = mkHost {
          stylixEnabled = true;
          modules = [ ./users/kopatz ./systems/pc/configuration.nix ];
        };
        "nix-laptop" = mkHost {
          specialArgs = {
            ## Custom variables (e.g. ip, interface, etc)
            vars = import ./systems/userdata-default.nix
              // import ./systems/laptop/userdata.nix;
            pkgsVersion = nixpkgs-unstable;
            inherit nix-colors;
          };
          modules = [
            ### User specific ###
            ./users/kopatz
            ./systems/laptop/configuration.nix
            ./modules/collections/laptop.nix
            ./modules/ecryptfs.nix
            ./modules/services/syncthing.nix
            ./modules/fh/scanning.nix
            ./modules/support/ntfs.nix
            ./modules/thunderbolt.nix
            #./modules/vmware-host.nix
            #./modules/fh/forensik.nix
            #./modules/no-sleep-lid-closed.nix
            #./modules/static-ip.nix
            #./modules/wake-on-lan.nix
            nixos-hardware.nixosModules.dell-xps-15-7590-nvidia
          ];
        };
        "mini-pc" = mkHost {
          specialArgs = {
            vars = import ./systems/userdata-default.nix;
            pkgsVersion = nixpkgs-unstable;
          };
          modules = [ ./users/anon ./systems/mini-pc/configuration.nix ];
        };
        # build vm -> nixos-rebuild build-vm  --flake .#vm
        "vm" = mkHost {
          specialArgs = {
            vars = import ./systems/userdata-default.nix;
            pkgsVersion = nixpkgs-unstable;
          };
          modules = [ ./users/vm ./systems/vm/configuration.nix ];
        };
        "wsl" = mkHost {
          modules = [
            #"${nixpkgs}/nixos/modules/profiles/minimal.nix"
            ./users/anon
            ./modules/nix/settings.nix
            ./systems/wsl/configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
        };
        #initial install done with nix run github:nix-community/nixos-anywhere/73a6d3fef4c5b4ab9e4ac868f468ec8f9436afa7 -- --flake .#adam-site root@<ip>
        #update with nixos-rebuild switch --flake .#adam-site --target-host "root@<ip>"
        "adam-site" = mkHost {
          minimal = true;
          system = "aarch64-linux";
          modules =
            [ disko.nixosModules.disko ./systems/adam-site/configuration.nix ];
        };
      };
    };
}
