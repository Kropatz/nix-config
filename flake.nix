{
  description = "Kop's NixOS Flake";
  inputs = {
      # secrets management
      agenix.url = "github:ryantm/agenix";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
      nixpkgs-kavita-update.url = "github:nevivurn/nixpkgs/feat/kavita-0.8.1";
      home-manager = {
        url = "github:nix-community/home-manager/release-23.11";
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
  };
  outputs = { self,
              nur,
              nixpkgs,
              nixos-hardware,
              nixos-wsl,
              nixpkgs-unstable,
              nixpkgs-kavita-update,
              agenix,
              home-manager,
              home-manager-unstable,
              nix-colors,
            }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
    in {
    overlays = import ./overlays.nix {inherit inputs;};

    nixosConfigurations.server = nixpkgs-unstable.lib.nixosSystem {
      inherit system;
      modules = [
        ./modules
        ./users/anon
        ./modules/collections/server.nix
        ./systems/server/configuration.nix
        ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages kavita-update]; })
        home-manager-unstable.nixosModules.home-manager
        agenix.nixosModules.default
      ];
      specialArgs = {
        ## Custom variables (e.g. ip, interface, etc)
        vars = import ./systems/userdata-default.nix // import ./systems/server/userdata.nix;
        pkgsVersion = nixpkgs-unstable;
        inherit inputs outputs;
      };
    };
    nixosConfigurations."kop-pc" = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          vars = import ./systems/userdata-default.nix // import ./systems/pc/userdata.nix;
          pkgsVersion = nixpkgs-unstable;
          inherit inputs outputs;
        };
        modules = [
          ./modules
          ./users/kopatz
          ./modules/collections/desktop.nix
          ./systems/pc/configuration.nix
         ({ config, pkgs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages nur.overlay]; })
          agenix.nixosModules.default
          home-manager-unstable.nixosModules.home-manager
        ];
    };
    nixosConfigurations."nix-laptop" = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          ## Custom variables (e.g. ip, interface, etc)
          vars = import ./systems/userdata-default.nix // import ./systems/laptop/userdata.nix;
          pkgsVersion = nixpkgs-unstable;
          inherit inputs outputs;
          inherit nix-colors;
        };
        modules = [
          ### User specific ###
          ./users/kopatz
          ./systems/laptop/configuration.nix
          ./modules/collections/laptop.nix
          ./modules
          ./modules/ecryptfs.nix
          ./modules/services/syncthing.nix
          ./modules/fh/scanning.nix
          ./modules/support/ntfs.nix
          ./modules/thunderbolt.nix
          ./modules/vmware-host.nix
          #./modules/fh/forensik.nix
          #./modules/no-sleep-lid-closed.nix
          #./modules/static-ip.nix
          #./modules/wake-on-lan.nix
          ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages nur.overlay]; })
          nixos-hardware.nixosModules.dell-xps-15-7590-nvidia
          agenix.nixosModules.default
          home-manager-unstable.nixosModules.home-manager
        ];
    };
    # build vm -> nixos-rebuild build-vm  --flake .#vm
    nixosConfigurations."vm" = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          vars = import ./systems/userdata-default.nix;
          pkgsVersion = nixpkgs-unstable;
          inherit inputs outputs;
        };
        modules = [
          ./modules
          ./users/vm
          ./systems/vm/configuration.nix
         ({ config, pkgs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages nur.overlay]; })
          agenix.nixosModules.default
          home-manager-unstable.nixosModules.home-manager
        ];
    };
    nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs; 
          pkgsVersion = nixpkgs-unstable;
        };
        modules = [
          #"${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./users/anon
          ./modules/nix/settings.nix
          ./systems/wsl/configuration.nix
          ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages]; })
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
        ];
    };
  };
}
