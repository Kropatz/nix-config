{
  description = "Kop's NixOS Flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix user repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ## stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable-new.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # nixpkgs-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    #home-manager-stable = {
    #  url = "github:nix-community/home-manager/release-25.11";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    # cosmic testing
    #nixos-cosmic = {
    #  url = "github:lilyinstarlight/nixos-cosmic";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    # vim configuration with nix
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # styling
    stylix = {
      url = "github:danth/stylix";
      # url = "github:make-42/stylix/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.home-manager.follows = "home-manager";
    };
    # disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #hyprland = {
    #  url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    #quickshell = {
    #  url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    # microvm = {
    #   url = "github:microvm-nix/microvm.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs =
    {
      self,
      nur,
      nixpkgs,
      nixpkgs-unstable-new,
      home-manager,
      nixos-hardware,
      #nixpkgs-stable,
      #home-manager-stable,
      # nixpkgs-unstable-small,
      agenix,
      #, nixos-cosmic
      nixvim,
      stylix,
      disko,
      flake-utils,
      deploy-rs,
      # microvm,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      overlays =
        { outputs, ... }:
        {
          nixpkgs.overlays = with outputs.overlays; [
            unstable-packages
            # unstable-small-packages
            #stable-packages
            additions
            modifications
            nur.overlays.default
          ];
        };
      defaultModules = [
        ./modules
        agenix.nixosModules.default
        overlays
      ];
      # helper function to create a machine
      mkHost =
        {
          modules,
          specialArgs ? {
            pkgsVersion = nixpkgs;
            home-manager-version = home-manager;
          },
          system ? "x86_64-linux",
          minimal ? false,
          graphical ? true,
        }:
        let
          lib = specialArgs.pkgsVersion.lib;
        in
        specialArgs.pkgsVersion.lib.nixosSystem {
          inherit system;
          modules =
            modules
            ++ defaultModules
            ++ lib.lists.optionals (!minimal) [ specialArgs.home-manager-version.nixosModules.home-manager ]
            ++ lib.lists.optionals (!minimal && graphical) [
              stylix.nixosModules.stylix
              # inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
              ./modules/opt-def/graphical/stylix.nix
              ./modules/opt-impl/nixos/graphical/stylix.nix
              #nixos-cosmic.nixosModules.default
              #./modules/graphical/cosmic.nix
              (
                { outputs, ... }:
                {
                  stylix.image = ./wallpaper/tsukasa.jpg;
                }
              )
            ];
          specialArgs = specialArgs // {
            inherit inputs outputs;
          };
        };
      customPackages = flake-utils.lib.eachDefaultSystem (system: {
        packages = import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; };
      });
      system = "x86_64-linux";
      # Unmodified nixpkgs
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
    in
    {
      overlays = import ./overlays.nix { inherit inputs; };

      nixosConfigurations = {
        "kop-pc" = mkHost {
          modules = [
            ./users/kopatz
            #./users/testuser
            ./systems/pc/configuration.nix
          ];
        };
        "test-pc" = mkHost {
          modules = [
            ./users/kopatz
            ./systems/test-pc/configuration.nix
          ];
        };

        "zel-mini-pc" = mkHost {
          graphical = false;
          modules = [
            disko.nixosModules.disko
            ./users/anon
            ./systems/zel-mini-pc/configuration.nix
            nixos-hardware.nixosModules.common-gpu-intel-kaby-lake
          ];
        };
        "framework" = mkHost {
          modules = [
            ### User specific ###
            disko.nixosModules.disko
            ./users/kopatz
            ./systems/laptop/configuration.nix
          ];
        };
        "dell" = mkHost {
          modules = [
            ### User specific ###
            disko.nixosModules.disko
            ./users/kopatz
            ./systems/dell/configuration.nix
          ];
        };
        "amd-server" = mkHost {
          modules = [
            ./users/kopatz
            ./systems/amd-server/configuration.nix
          ];
        };
        "amd-server-vpn-vm" = mkHost {
          modules = [
            ./users/anon
            ./systems/amd-server-vpn-vm/configuration.nix
            disko.nixosModules.disko
          ];
        };
        # build vm -> nixos-rebuild build-vm  --flake .#vm
        "vm" = mkHost {
          modules = [
            ./users/vm
            ./systems/vm/configuration.nix
          ];
        };
        # nixos-rebuild switch --flake .#server-vm --target-host root@192.168.0.21
        "server-vm" = mkHost {
          minimal = true;
          modules = [
            ./users/anon
            ./systems/amd-server-vm/configuration.nix
            disko.nixosModules.disko
          ];
        };
        "amd-server-exposed-vm" = mkHost {
          minimal = true;
          modules = [
            ./users/anon
            ./systems/amd-server-exposed-vm/configuration.nix
            disko.nixosModules.disko
            # microvm.nixosModules.host
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

      deploy.nodes = {
        server-vm = {
          hostname = "kopatz.dev";
          profiles.system = {
            sshUser = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.server-vm;
          };
        };
        amd-server = {
          hostname = "192.168.0.20";
          profiles.system = {
            sshUser = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.amd-server;
          };
        };
        amd-server-vpn-vm = {
          hostname = "192.168.0.132";
          profiles.system = {
            sshUser = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.amd-server-vpn-vm;
          };
        };
        amd-server-exposed-vm = {
          hostname = "192.168.0.22";
          profiles.system = {
            sshUser = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.amd-server-exposed-vm;
          };
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
