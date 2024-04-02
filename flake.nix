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
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ### User specific ###
        ./users/anon
        ### System sepecific ###
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        ./systems/server/configuration.nix
        ### Modules ###
        ./modules/cli-tools.nix
        ./modules/static-ip.nix
        ./modules/hdd-spindown.nix
        ./modules/firewall.nix
        ./modules/motd.nix
        ./modules/postgres.nix
        ./modules/fail2ban.nix
        ./modules/nix/settings.nix
        ./modules/adguard.nix
        ./modules/git.nix
        ./modules/github-runner.nix
        ./modules/nextcloud.nix
        ./modules/acme.nix
        ./modules/samba.nix
        ./modules/backup.nix
        ./modules/nginx.nix
        ./modules/ssh.nix
        ./modules/docker.nix
        ./modules/wireguard.nix
        ./modules/cron.nix
        ./modules/kavita.nix
        ./modules/netdata.nix
        ./modules/step-ca.nix
        ./modules/tmpfs.nix
        #./modules/games/palworld.nix
        ./modules/logging.nix
        ### Hardware ###
        ./modules/hardware/ssd.nix
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
      ];
      specialArgs = {
        ## Custom variables (e.g. ip, interface, etc)
        vars = import ./systems/userdata-default.nix // import ./systems/server/userdata.nix;
        pkgsVersion = nixpkgs;
        inherit inputs ;
      };
    };
    nixosConfigurations."kop-pc" = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          vars = import ./systems/userdata-default.nix // import ./systems/pc/userdata.nix;
          pkgsVersion = nixpkgs-unstable;
          inherit inputs ;
        };
        modules = [
          ### User specific ###
          ./users/kopatz
          ### System modules ###
          ./modules/graphical/plasma.nix
          #./modules/graphical/hyprland.nix
          ./modules/graphical/emulators.nix
          ./modules/graphical/gamemode.nix
          ./modules/graphical/obs.nix
          ./modules/graphical/audio.nix
          ./modules/graphical/games.nix
          ./modules/graphical/ime.nix
          ./modules/graphical/code.nix
          ./modules/graphical/shared.nix
          #./modules/fh/forensik.nix
          ./modules/hardware/nvidia.nix
          ./modules/hardware/ssd.nix
          ./modules/hardware/firmware.nix
          ./modules/kernel.nix # use latest kernel
          ./modules/nix/settings.nix
          ./modules/nix/index.nix
          ./modules/nix/ld.nix
          ./modules/cli-tools.nix
          ./modules/gpg.nix
          ./modules/virt-manager.nix
          #./modules/hardware/vfio.nix too stupid for this
          ./modules/flatpak.nix
          ./modules/docker.nix
          ./modules/nftables.nix
          ./modules/noise-supression.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./modules/wooting.nix
          ./modules/wireshark.nix
          ./modules/tmpfs.nix
          ./modules/support/ntfs.nix
          ./systems/pc/configuration.nix
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
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./modules/graphical/hyprland.nix
          ./modules/graphical/emulators.nix
          ./modules/graphical/gamemode.nix
          ./modules/graphical/audio.nix
          ./modules/graphical/games.nix
          ./modules/graphical/ime.nix
          ./modules/graphical/code.nix
          ./modules/graphical/shared.nix
          #./modules/fh/forensik.nix
          ./systems/laptop/configuration.nix
          ./modules/cli-tools.nix
          ./modules/ecryptfs.nix
          ./modules/pentest.nix
          ./modules/virt-manager.nix
          ./modules/vmware-host.nix
          ./modules/nix/ld.nix
          ./modules/ssh.nix
          ./modules/wireshark.nix
          #./modules/static-ip.nix
          #./modules/no-sleep-lid-closed.nix
          #./modules/wake-on-lan.nix
          ./modules/thunderbolt.nix
          ./modules/rdp.nix
          ./modules/tmpfs.nix
          ./modules/support/ntfs.nix
          ./modules/nix/settings.nix
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
          ./modules/nix/settings.nix
          ./modules/cli-tools.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./systems/wsl/configuration.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
        ];
    };
  };
}
