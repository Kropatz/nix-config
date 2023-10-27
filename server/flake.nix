{
  description = "A very basic flake";
  inputs = {
      # secrets management
      agenix.url = "github:ryantm/agenix";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
      nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, agenix }@inputs:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
    in {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ 
	./modules/static-ip-server.nix
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
        ./configuration.nix 
        ./modules/nix-settings.nix
        ./modules/adguard.nix
        ./modules/git.nix
        #./modules/vmware-guest.nix
        ./modules/github-runner.nix

        ./modules/nextcloud.nix
	./modules/coturn.nix

        ./modules/acme.nix
        ./modules/samba.nix
        ./modules/backup.nix
        ./modules/nginx.nix
        ./modules/ssh.nix
        ./modules/rdp.nix
        ./modules/docker.nix
	./modules/wireguard.nix
        #./modules/dyndns.nix i think ddclient is deprecated
        #./modules/home-assistant.nix idk dont like this
        agenix.nixosModules.default
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
