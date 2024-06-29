{ pkgs, config, lib, modulesPath, ... }: {

  imports = [ ./vm-common.nix (modulesPath + "/profiles/qemu-guest.nix") ];
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];
  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    user = {
      name = "vm";
      layout = "de";
      variant = "us";
    };
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    graphical = {
      #i3.enable = true;
      plasma.enable = true;
      #lightdm.enable = true;
      #sddm.enable = true;
      #cosmic.enable = true;
    };
  };
  networking.networkmanager.enable = true;
  virtualisation.vmVariant = {
    virtualisation.qemu.options = [ "-vga qxl" ];
    #[ "-vga none" "-device virtio-gpu-gl-pci" "-display default,gl=on" ];
  };

  environment.systemPackages = with pkgs; [ firefox ];

}
