{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.tpm;
in
{
  options.custom.hardware.tpm = {
    enable = mkEnableOption "Enables tpm";
  };

  config = mkIf cfg.enable {

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
  };
}
