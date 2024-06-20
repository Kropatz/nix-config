{ pkgs, lib, ... }: {
  services.xserver = {
    enable = true;
    displayManager = {
      autoLogin.enable = false;
      autoLogin.user = "vm";
    };

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
}
