{ config, pkgs, lib, inputs, ... }:
let cfg = config.custom.services.opensnitch;
in {
  options.custom.services.opensnitch = {
    enable = lib.mkEnableOption "Enables opensnitch";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.opensnitch-ui ];
    services.opensnitch = {
      enable = true;
      rules = {
        systemd-timesyncd = {
          name = "systemd-timesyncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
          };
        };
        systemd-resolved = {
          name = "systemd-resolved";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
          };
        };
      };
    };
  };
}
