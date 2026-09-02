{ lib, config, ... }:
{
  options.custom.hardware = {
    amd-gpu = {
      enable = lib.mkEnableOption "Enables amd gpus";
      overdrive = lib.mkEnableOption "Enables overdrive";
      rocm.enable = lib.mkEnableOption "Enables rocm";
    };
    android.enable = lib.mkEnableOption "Enables android phone support";
    fingerprint.enable = lib.mkEnableOption "Enables fingerprint sensor support";
    firmware.enable = lib.mkEnableOption "Enables firmware";
    nvidia = {
      enable = lib.mkEnableOption "Enables nvidia gpus";
      package = lib.mkOption {
        type = lib.types.package;
        default = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      powerLimit = {
        enable = lib.mkEnableOption "Increase GPU power limit";
        wattage = lib.mkOption {
          type = lib.types.int;
          default = 300;
          description = "The power limit to set the GPU to";
        };
      };
      clock = {
        enable = lib.mkEnableOption "Set GPU clocks";
        min = lib.mkOption {
          type = lib.types.int;
          description = "The minimum GPU clock to set";
        };
        max = lib.mkOption {
          type = lib.types.int;
          description = "The maximum GPU clock to set";
        };
        offset = lib.mkOption {
          type = lib.types.int;
          description = "The GPU clock offset to set";
        };
      };
    };
    scheduler.enable = lib.mkEnableOption "Enables scheduler";
    ssd.enable = lib.mkEnableOption "Enables fstrim";
    tablet.enable = lib.mkEnableOption "Enables tablet";
    tpm.enable = lib.mkEnableOption "Enables tpm";
    vfio = {
      enable = lib.mkEnableOption "Enables vfio";
      stub_pci = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "List of PCI devices to stub with vfio-pci";
      };
    };
    vr = {
      enable = lib.mkEnableOption "Enables amd gpus";
      overdrive = lib.mkEnableOption "Enables overdrive";
      rocm.enable = lib.mkEnableOption "Enables rocm";
    };
    wooting.enable = lib.mkEnableOption "Enable wooting hardware support";
  };
}
