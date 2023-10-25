{
  description = "A very basic flake";
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./configuration.nix 
        ./modules/nix-settings.nix
        ./modules/adguard.nix
        ./modules/git.nix
        ./modules/vmware-guest.nix
        #./modules/home-assistant.nix idk dont like this
      ];
    };
  };
}
