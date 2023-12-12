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
      nixos-wsl = {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixinate.url = "github:matthewcroughan/nixinate";
      nix-colors.url = "github:misterio77/nix-colors";
  };
  outputs = { self,
              nixpkgs,
              nixos-hardware,
              nixos-wsl,
              nixpkgs-unstable,
              agenix,
              home-manager,
              nixinate,
              nix-colors,
            }@inputs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
    in {
    apps = nixinate.nixinate.${system} self;
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ### User specific ###
        ./users/anon.nix
        ./users/option.nix
        ### System sepecific ###
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        ./systems/server/configuration.nix
        ### Modules ###
        ./modules/cli-tools.nix
        ./modules/static-ip.nix
        ./modules/hdd-spindown.nix
        ./modules/firewall.nix
        ./modules/wireshark.nix
        ./modules/minecraft-server.nix
        ./modules/motd.nix
        ./modules/postgres.nix
        ./modules/fail2ban.nix
        ./modules/nix/settings.nix
        ./modules/adguard.nix
        ./modules/git.nix
        ./modules/github-runner.nix
        ./modules/synapse.nix
        ./modules/nextcloud.nix
        ./modules/acme.nix
        ./modules/samba.nix
        ./modules/backup.nix
        ./modules/nginx.nix
        ./modules/ssh.nix
        ./modules/rdp.nix
        ./modules/docker.nix
        ./modules/wireguard.nix
        ./modules/cron.nix
        ./modules/paperless.nix
        ./modules/kavita.nix
        ./modules/netdata.nix
        ./modules/invidious.nix
        ./modules/step-ca.nix
        ./modules/tmpfs.nix
        ./modules/logging.nix
        ### Hardware ###
        ./modules/hardware/ssd.nix
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        {
          _module.args.nixinate = {
            host = "192.168.2.1";
            sshUser = "anon";
            buildOn = "remote"; # valid args are "local" or "remote"
            substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
            hermetic = false;
          };
        }
      ];
      specialArgs = {
        ## Custom variables (e.g. ip, interface, etc)
        vars = import ./systems/userdata-default.nix // import ./systems/server/userdata.nix;
        inherit inputs ;
      };
    };
    nixosConfigurations."kop-pc" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          vars = import ./systems/userdata-default.nix // import ./systems/pc/userdata.nix;
          inherit inputs ;
        };
        modules = [
          ### User specific ###
          ./users/kopatz
          ### System modules ###
          ./modules/graphical/plasma.nix
          ./modules/graphical/hyprland.nix
          ./modules/graphical/emulators.nix
          ./modules/graphical/gamemode.nix
          ./modules/graphical/obs.nix
          ./modules/graphical/shared.nix
          ./modules/hardware/nvidia.nix
          ./modules/hardware/ssd.nix
          ./modules/hardware/firmware.nix
          #./modules/hardware/scheduler.nix
          # use latest kernel
          ./modules/kernel.nix
          ./modules/cli-tools.nix
          ./modules/nix/settings.nix
          ./modules/nix/index.nix
          ./modules/nix/ld.nix
          ./modules/gpg.nix
          ./modules/virt-manager.nix
          ./modules/flatpak.nix
          ./modules/noise-supression.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./modules/wooting.nix
          ./modules/wireshark.nix
          ./modules/tmpfs.nix
          ./modules/support/ntfs.nix
          ./systems/pc/configuration.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
    };
    nixosConfigurations."nix-laptop" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          ## Custom variables (e.g. ip, interface, etc)
          vars = import ./systems/userdata-default.nix // import ./systems/laptop/userdata.nix;
          inherit inputs;
          inherit nix-colors;
        };
        modules = [
          ### User specific ###
          ./users/kopatz
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          # Todo: refactor file layout
          ./modules/graphical/hyprland.nix
          ./modules/graphical/shared.nix
          ./laptop/configuration.nix
          ./modules/cli-tools.nix
          ./modules/virt-manager.nix
          ./modules/vmware-host.nix
          ./modules/ssh.nix
          #./modules/static-ip.nix
          #./modules/no-sleep-lid-closed.nix
          #./modules/wake-on-lan.nix
          ./modules/thunderbolt.nix
          ./modules/rdp.nix
          ./modules/tmpfs.nix
          ./modules/nix/settings.nix
          nixos-hardware.nixosModules.dell-xps-15-7590-nvidia
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
    };
    nixosConfigurations."nix-laptop-no-gpu" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          ## Custom variables (e.g. ip, interface, etc)
          vars = (import ./systems/laptop/userdata.nix);
          inherit inputs ;
        };
        modules = [
          ### User specific ###
          ./users/option.nix
          ./users/kopatz.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./laptop/configuration.nix
          ./modules/graphical/shared.nix
          ./modules/cli-tools.nix
          ./modules/virt-manager.nix
          ./modules/ssh.nix
          ./modules/wake-on-lan.nix
          ./modules/static-ip.nix
          ./modules/no-sleep-lid-closed.nix
          ./modules/thunderbolt.nix
          ./modules/nix/settings.nix
          nixos-hardware.nixosModules.dell-xps-15-7590
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
    };
    nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs ;};
        modules = [
          #"${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./users/anon.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./systems/wsl/configuration.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
        ];
    };
  };
}
