{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.hardware;
in
{
  imports = [
    ./amd-gpu.nix
    ./nvidia.nix
    ./vfio.nix
    ./wooting.nix
    ./usb-recovery.nix
    ./vr.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.android.enable {
      environment.systemPackages = with pkgs; [
        scrcpy # mirrors screen to pc, -S turns off screen while active, --render-driver opengl uses opengl for rendering
        android-tools
      ];
      users.users.${config.mainUser.name}.extraGroups = [ "adbusers" ];
    })
    (lib.mkIf cfg.fingerprint.enable {
      services.fprintd = {
        enable = true;
      };
    })
    (lib.mkIf cfg.firmware.enable {
      services.fwupd.enable = true;
    })
    (lib.mkIf cfg.scheduler.enable {
      services.system76-scheduler = {
        enable = true;
      };

      hardware.system76.enableAll = true;
    })
    (lib.mkIf cfg.ssd.enable {
      services.fstrim.enable = true;
    })
    (lib.mkIf cfg.tablet.enable {
      hardware.opentabletdriver.enable = true;
    })
    (lib.mkIf cfg.tpm.enable {
      security.tpm2 = {
        enable = true;
        # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
        pkcs11.enable = true;
        # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
        tctiEnvironment.enable = true;
      };

      #tss group has access to TPM devices
      users.users.${config.mainUser.name}.extraGroups = [ "tss" ];
      environment.systemPackages = with pkgs; [ tpm2-tools ];
    })
  ];
}
