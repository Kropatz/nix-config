{ pkgs, config, lib, modulesPath, ... }: {

  imports = [
    ./vm-common.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    #(modulesPath + "/profiles/minimal.nix")
  ];
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];
  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    user = {
      name = "vm";
      layout = "de";
      variant = "us";
    };
    nix = {
      settings.enable = true;
      settings.optimise = false;
    };
    graphical = {
      #i3.enable = true;
      #hyprland.enable = true;
      #lightdm.enable = true;
      #sddm.enable = true;
      #cosmic.enable = true;
    };
    services = {
      kavita = {
        enable = true;
        https = false;
        autoDownload = false;
        isTest = true;
      };
    };
  };
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };

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
