{ pkgs, inputs, ... }:
{
  microvm.vms = {
    my-microvm = {
      # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
      specialArgs = {
        index = 1;
      };

      # The configuration for the MicroVM.
      # Multiple definitions will be merged as expected.
      config = {
        imports = [
          ../../modules/default.nix
          ../../modules/opt-impl/nixos/services/ssh.nix
          ../../users/default.nix
          ../../modules/opt-impl/nixos/microvm/routed-network-guest.nix
          inputs.agenix.nixosModules.default
        ];
        # It is highly recommended to share the host's nix-store
        # with the VMs to prevent building huge images.

        mainUser.sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 kopatz";
        environment.systemPackages = with pkgs; [
          btop
          gdu
        ];
        microvm = {
          hotpluggedMem = 256;
          hotplugMem = 1024;
          hypervisor = "cloud-hypervisor";
          graphics.enable = true; # error: attribute 'cloud-hypervisor-graphics' missing
          shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];
        };

        # Any other configuration for your MicroVM
        # [...]
      };
    };
  };
}
