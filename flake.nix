{
  description = "Kop's NixOS Flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # nix user repository
    nur = { url = "github:nix-community/NUR"; };
    ## stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    ## unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-gimp3.url = "github:jtojnar/nixpkgs/gimp-meson";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # cosmic testing
    #nixos-cosmic = {
    #  url = "github:lilyinstarlight/nixos-cosmic";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};
    # vim configuration with nix
    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };
    # styling
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };
    # disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    { self
    , nur
    , nixpkgs
    , nixos-hardware
    , nixpkgs-unstable
    , agenix
    , home-manager
    , home-manager-unstable
    , nix-colors
      #, nixos-cosmic
    , nixvim
    , nixos-generators
    , stylix
    , disko
    , flake-utils
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      overlays = { outputs, ... }: {
        nixpkgs.overlays = with outputs.overlays; [
          #unstable-packages
          additions
          modifications
          nur.overlays.default
        ];
      };
      defaultModules = [ ./modules agenix.nixosModules.default overlays ];
      # helper function to create a machine
      mkHost =
        { modules
        , specialArgs ? {
            pkgsVersion = nixpkgs-unstable;
            home-manager-version = home-manager-unstable;
          }
        , system ? "x86_64-linux"
        , minimal ? false
        , graphical ? true
        }:
        let lib = specialArgs.pkgsVersion.lib;
        in specialArgs.pkgsVersion.lib.nixosSystem {
          inherit system;
          modules = modules ++ defaultModules ++ lib.lists.optionals (!minimal)
            [ specialArgs.home-manager-version.nixosModules.home-manager ]
            ++ lib.lists.optionals (!minimal && graphical) [
            ./modules/graphical
            stylix.nixosModules.stylix
            ./modules/graphical/stylix.nix
            #nixos-cosmic.nixosModules.default
            #./modules/graphical/cosmic.nix
            ({ outputs, ... }: { stylix.image = ./tsukasa.jpg; })
          ];
          specialArgs = specialArgs // { inherit inputs outputs; };
        };
      mkStableServer =
        { modules
        , specialArgs ? {
            pkgsVersion = nixpkgs;
            home-manager-version = home-manager;
          }
        , system ? "x86_64-linux"
        , minimal ? false
        }:
        let lib = specialArgs.pkgsVersion.lib;
        in specialArgs.pkgsVersion.lib.nixosSystem {
          inherit system;
          modules = modules
            ++ [ ./modules agenix.nixosModules.default overlays ]
            ++ lib.lists.optionals (!minimal)
            [ specialArgs.home-manager-version.nixosModules.home-manager ];
          specialArgs = specialArgs // { inherit inputs outputs; };
        };
      customPackages = flake-utils.lib.eachDefaultSystem (system: {
        packages =
          import ./pkgs { pkgs = nixpkgs-unstable.legacyPackages.${system}; }
          // {
            "server-vm" = nixos-generators.nixosGenerate {
              format = "vmware";
              inherit system;
              specialArgs = {
                pkgsVersion = nixpkgs-unstable;
              } // {
                inherit inputs outputs;
              };
              lib = nixpkgs-unstable.legacyPackages.x86_64-linux.lib;
              modules = defaultModules ++ [
                home-manager-unstable.nixosModules.home-manager
                ./users/anon
                ./systems/amd-server-vm/configuration.nix
                {
                  # 100G disk;
                  virtualisation.diskSize = 100 * 1024;
                }
              ];
            };
          };
      });
    in
    {
      overlays = import ./overlays.nix { inherit inputs; };

      nixosConfigurations = {
        "kop-pc" = mkHost {
          modules = [ ./users/kopatz ./systems/pc/configuration.nix ];
        };
        "nix-laptop" = mkHost {
          specialArgs = {
            ## Custom variables (e.g. ip, interface, etc)
            vars = import ./systems/userdata-default.nix
              // import ./systems/laptop/userdata.nix;
            pkgsVersion = nixpkgs-unstable;
            home-manager-version = home-manager-unstable;
            inherit nix-colors;
          };
          modules = [
            ### User specific ###
            ./users/kopatz
            ./systems/laptop/configuration.nix
            ./modules/collections/laptop.nix
          ];
        };
        "mini-pc" = mkStableServer {
          modules = [ ./users/anon ./systems/mini-pc/configuration.nix ];
        };
        "mini-pc-proxmox" = mkStableServer {
          modules =
            [ ./users/anon ./systems/mini-pc-proxmox/configuration.nix ];
        };
        #initial install done with nix run github:nix-community/nixos-anywhere/73a6d3fef4c5b4ab9e4ac868f468ec8f9436afa7 -- --flake .#adam-site root@<ip>
        #update with nixos-rebuild switch --flake .#adam-site --target-host "root@<ip>"
        "adam-site" = mkStableServer {
          minimal = true;
          system = "aarch64-linux";
          specialArgs = {
            pkgsVersion = nixpkgs;
            home-manager-version = home-manager;
          };
          modules =
            [ disko.nixosModules.disko ./systems/adam-site/configuration.nix ];
        };
        "proxmox-test-vm" = mkHost {
          minimal = true;
          modules = [
            disko.nixosModules.disko
            ./systems/proxmox-test-vm/configuration.nix
          ];
        };
        "amd-server" = mkHost {
          modules = [ ./users/kopatz ./systems/amd-server/configuration.nix ];
        };
        # build vm -> nixos-rebuild build-vm  --flake .#vm
        "vm" =
          mkHost { modules = [ ./users/vm ./systems/vm/configuration.nix ]; };
        # nixos-rebuild switch --flake .#server-vm --target-host root@192.168.0.21 
        "server-vm" = mkHost {
          modules = [
            ./users/anon
            ./systems/amd-server-vm/configuration.nix
            disko.nixosModules.disko
          ];
        };
        "portable-ssd" = mkHost {
          modules = [
            ./users/kopatz
            ./systems/portable-ssd/configuration.nix
          ];
        };
      };

      packages = customPackages.packages;
    };
}
