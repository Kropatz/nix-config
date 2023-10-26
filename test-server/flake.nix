{
  description = "A very basic flake";
  inputs = {
      # secrets management
      agenix.url = "github:ryantm/agenix";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };
  outputs = { self, nixpkgs, agenix }@inputs: {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
	      ./modules/ip-server.nix
        ./configuration.nix 
        ./modules/nix-settings.nix
        ./modules/adguard.nix
        ./modules/git.nix
        #./modules/vmware-guest.nix
        ./modules/github-runner.nix
        ./modules/nextcloud.nix
        ./modules/acme.nix
        ./modules/samba.nix
        ./modules/backup.nix
        ./modules/nginx.nix
        ./modules/ssh.nix
        ./modules/rdp.nix
        #./modules/dyndns.nix i think ddclient is deprecated
        #./modules/home-assistant.nix idk dont like this
        agenix.nixosModules.default
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
