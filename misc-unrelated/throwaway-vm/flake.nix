{
  description = "Small NixOS VM with syncthing on a unix socket";

  # inputs.nixpkgs.url = "github:Kropatz/nixpkgs/fix-syncthing";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };

    # convenience wrappers
    packages.x86_64-linux.vm =
      self.nixosConfigurations.vm.config.system.build.vm;

    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.nixosConfigurations.vm.config.system.build.vm}/bin/run-nixos-vm";
    };
  };
}
