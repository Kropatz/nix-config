{ config, pkgs, ... }:
{
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings
  environment.systemPackages = with pkgs; [ virt-manager virtiofsd ];
  environment.sessionVariables.GSETTINGS_BACKEND = "keyfile";

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;  
  users.users.${config.mainUser.name}.extraGroups = [ "libvirtd" ];
}
