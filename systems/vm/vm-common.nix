{ pkgs, lib, ... }: {
  services.xserver = {
    enable = true;
    resolutions = lib.mkOverride 9 ([ ] ++ [{
      x = 1680;
      y = 1050;
    }]);
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 8;
      graphics = true; # Boot the vm in a window.
    };
  };
  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0" ];
    loader.timeout = lib.mkForce 1;

    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };
}
