{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    ./vm-common.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
    #(modulesPath + "/profiles/minimal.nix")
  ];
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];
  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    nix = {
      settings.enable = true;
      settings.optimise = false;
    };
    graphical = {
      #i3.enable = true;
      #hyprland.enable = true;
      #lightdm.enable = true;
      #sddm.enable = true;
      #plasma.enable = true;
      #cosmic.enable = true;
    };
  };
  #services.xserver = {
  #  enable = true;
  #  desktopManager = {
  #    xterm.enable = false;
  #    xfce.enable = true;
  #  };
  #  displayManager.defaultSession = "xfce";
  #};

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  programs.sway.enable = true;

  virtualisation.qemu.options = [
    "-device virtio-vga"
  ];

  programs.firefox.enable = true;

  virtualisation.vmVariant = {
    #virtualisation.qemu.options = [
    #      "-device virtio-vga-gl"
    #      "-display sdl,gl=on,show-cursor=off"
    #      "-audio pa,model=hda"
    #      #"-full-screen"
    #    ];
    #virtualisation.qemu.options = [ "-vga qxl" ];
    #[ "-vga none" "-device virtio-gpu-gl-pci" "-display default,gl=on" ];
  };
}
