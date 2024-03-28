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
        ### User specific ###
        ./users/anon
        ### System sepecific ###
        ./systems/server/configuration.nix
        ### Services ###
        ./modules/services/acme.nix
        ./modules/services/adguard.nix
        ./modules/services/github-runner.nix
        ./modules/services/kavita.nix
        ./modules/services/netdata.nix
        ./modules/services/nextcloud.nix
        ./modules/services/samba.nix
        ./modules/services/step-ca.nix
        ### Other Modules ###
        #./modules/games/palworld.nix
        ./modules/backup.nix
        ./modules/cli-tools.nix
        ./modules/cron.nix
        ./modules/docker.nix
        ./modules/fail2ban.nix
        ./modules/firewall.nix
        ./modules/git.nix
        ./modules/hdd-spindown.nix
        ./modules/logging.nix
        ./modules/motd.nix
        ./modules/nix/settings.nix
        ./modules/postgres.nix
        ./modules/services/nginx.nix
        ./modules/ssh.nix
        ./modules/static-ip.nix
        ./modules/tmpfs.nix
        ./modules/wireguard.nix
        ### Hardware ###
        ./modules/hardware/ssd.nix
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
          ### User specific ###
          ./users/kopatz
          ### System modules ###
          ./modules/cli-tools.nix
          ./modules/docker.nix
          ./modules/flatpak.nix
          ./modules/gpg.nix
          ./modules/graphical/audio.nix
          ./modules/graphical/code.nix
          ./modules/graphical/emulators.nix
          ./modules/graphical/gamemode.nix
          ./modules/graphical/games.nix
          ./modules/graphical/ime.nix
          ./modules/graphical/obs.nix
          ./modules/graphical/plasma.nix
          ./modules/graphical/shared.nix
          ./modules/hardware/firmware.nix
          ./modules/hardware/nvidia.nix
          ./modules/hardware/ssd.nix
          ./modules/kernel.nix # use latest kernel
          ./modules/nftables.nix
          ./modules/nix/index.nix
          ./modules/nix/ld.nix
          ./modules/nix/settings.nix
          ./modules/noise-supression.nix
          ./modules/support/ntfs.nix
          ./modules/tmpfs.nix
          ./modules/virt-manager.nix
          ./modules/wireshark.nix
          ./modules/wooting.nix
          ./systems/pc/configuration.nix
          #./modules/fh/forensik.nix
          #./modules/graphical/hyprland.nix
          #./modules/hardware/vfio.nix too stupid for this
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
          ./modules/rdp.nix
          ./modules/ssh.nix
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
