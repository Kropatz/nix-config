{lib,  config, pkgs, ... }:
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
        hooks.qemu = {
         # doesnt work, screen just freezes. no error in libvirt logs though, so idk how to fix it
         "passthrough" = lib.getExe (
          pkgs.writeShellApplication {
            name = "qemu-hook";
            excludeShellChecks = [ "SC2046" "SC2086" ];

            runtimeInputs = with pkgs; [
              libvirt
              systemd
              kmod
            ];
            text = builtins.readFile ./hook.sh;
          }
        );
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;  
    users.users.${config.mainUser.name}.extraGroups = [ "libvirtd" ];
  };
}

