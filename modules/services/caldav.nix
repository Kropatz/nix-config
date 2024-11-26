{ config, pkgs, lib, inputs, ... }:
let cfg = config.custom.services.caldav;
in {
  options.custom.services.caldav = {
    enable = lib.mkEnableOption "Enables caldav server";
  };
  config = lib.mkIf cfg.enable {
    age.secrets.radicale-users = {
      file = ../../secrets/radicale.age;
      owner = "radicale";
    };
    services.radicale = {
      enable = true;
      settings = {
        server = { hosts = [ "127.0.0.1:5232" ]; };
        #server = { hosts = [ "192.168.0.11:5232" ]; };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.age.secrets.radicale-users.path;
          htpasswd_encryption = "bcrypt";
        };
        storage = { filesystem_folder = "/var/lib/radicale/collections"; };
      };
    };
    custom.misc.backup = lib.mkIf config.custom.misc.backup.enable {
      small = [ "/var/lib/radicale/" ];
      medium = [ "/var/lib/radicale/" ];
      large = [ "/var/lib/radicale/" ];
    };

    systemd.services.kop-fhcalendar = let
      radicale = if lib.versionOlder lib.version "25.05" then
        (builtins.elemAt
          config.services.radicale.settings.storage.filesystem_folder 0)
      else
        config.services.radicale.settings.storage.filesystem_folder;
      # not reproducible
      working =
        "${radicale}/collection-root/kopatz/b6d2c446-8109-714a-397f-1f35d3136639";
    in {
      description = "Download fh calendar";
      wants = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "*-*-* 06:00:00";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kop-fhcalendar}/bin/kop-fhcalendar";
        WorkingDirectory = working;
        BindPaths = [ working ];
        User = "radicale";
        Restart = "on-failure";
        RestartSec = "5s";
        PrivateMounts = lib.mkDefault true;
        PrivateTmp = lib.mkDefault true;
        PrivateUsers = lib.mkDefault true;
        ProtectClock = lib.mkDefault true;
        ProtectControlGroups = lib.mkDefault true;
        ProtectHome = lib.mkDefault true;
        ProtectHostname = lib.mkDefault true;
        ProtectKernelLogs = lib.mkDefault true;
        ProtectKernelModules = lib.mkDefault true;
        ProtectKernelTunables = lib.mkDefault true;
        ProtectSystem = lib.mkDefault "strict";
        # Needs network access
        PrivateNetwork = lib.mkDefault false;
      };
    };
  };
}
