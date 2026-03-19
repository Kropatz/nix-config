{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.virt-manager;
in
{
  options.custom.virt-manager = {
    enable = mkEnableOption "Enables virt-manager";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true; # virt-manager requires dconf to remember settings
    environment.systemPackages = with pkgs; [ virtiofsd ];
    environment.sessionVariables.GSETTINGS_BACKEND = "keyfile";
    boot.extraModprobeConfig = ''
      options kvm ignore_msrs=1
    '';
    networking.firewall.trustedInterfaces = [ "virbr0" ];
    programs.virt-manager.enable = true;
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          #package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
    users.users.${config.mainUser.name}.extraGroups = [
      "libvirtd"
      "kvm"
      "input"
    ];
  };
}
