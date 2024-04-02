{
  description = "Kop's NixOS Flake";
  inputs = {
      # secrets management
      agenix.url = "github:ryantm/agenix";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
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
  };
  outputs = { self,
              nixpkgs,
              nixos-hardware,
              nixos-wsl,
              nixpkgs-unstable,
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

    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./users/anon
        ./modules/collections/server.nix
        ./systems/server/configuration.nix
        ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages]; })
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
      ];
      specialArgs = {
        ## Custom variables (e.g. ip, interface, etc)
        vars = import ./systems/userdata-default.nix // import ./systems/server/userdata.nix;
        pkgsVersion = nixpkgs;
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
          ./users/kopatz
          ./modules/collections/desktop.nix
          ./systems/pc/configuration.nix
         ({ config, pkgs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages]; })
          agenix.nixosModules.default
          home-manager-unstable.nixosModules.home-manager
        ];
    };
    nixosConfigurations."nix-laptop" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          ## Custom variables (e.g. ip, interface, etc)
          vars = import ./systems/userdata-default.nix // import ./systems/laptop/userdata.nix;
          pkgsVersion = nixpkgs;
          inherit inputs;
          inherit nix-colors;
        };
        modules = [
          ### User specific ###
          ./users/kopatz
          ./modules/cli-tools.nix
          ./modules/ecryptfs.nix
          ./modules/pentest.nix
          ./modules/graphical/audio.nix
          ./modules/graphical/code.nix
          ./modules/graphical/emulators.nix
          ./modules/graphical/gamemode.nix
          ./modules/graphical/games.nix
          ./modules/graphical/hyprland.nix
          ./modules/graphical/ime.nix
          ./modules/graphical/shared.nix
          ./modules/nix/ld.nix
          ./modules/nix/settings.nix
          ./modules/support/ntfs.nix
          ./modules/thunderbolt.nix
          ./modules/tmpfs.nix
          ./modules/virt-manager.nix
          ./modules/vmware-host.nix
          ./modules/wireshark.nix
          ./systems/laptop/configuration.nix
          #./modules/fh/forensik.nix
          #./modules/no-sleep-lid-closed.nix
          #./modules/static-ip.nix
          #./modules/wake-on-lan.nix
          ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages]; })
          nixos-hardware.nixosModules.dell-xps-15-7590-nvidia
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
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
          ./modules/cli-tools.nix
          ./modules/nix/settings.nix
          ./systems/wsl/configuration.nix
          ({ config, outputs, ... }: { nixpkgs.overlays = with outputs.overlays; [additions modifications unstable-packages]; })
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
        ];
    };
  };
}
