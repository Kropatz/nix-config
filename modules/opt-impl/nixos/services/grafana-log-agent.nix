{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  cfg = config.custom.services.grafana-log-agent;
  base = "/mnt/tmpfs";
  dirOwner = if config.services.grafana.enable
    then "grafana"
    else "fluent-bit";
in
{
  config = lib.mkIf cfg.enable {
    fileSystems = {
      "${base}" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "size=2G"
          "mode=1777"
        ];
      };
    };
    systemd.tmpfiles.rules = [
      "d ${base} 0755 ${dirOwner} ${dirOwner} -"
      "d ${base}/fluent-bit 0750 fluent-bit ${dirOwner} -"
    ];

    users.users.fluent-bit = {
      isSystemUser = true;
      group = "fluent-bit";
    };
    users.groups.fluent-bit = { };
    systemd.services.fluent-bit.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "fluent-bit";
      Group = lib.mkForce "fluent-bit";
      WorkingDirectory = lib.mkForce "${base}/fluent-bit";
      ReadWritePaths = lib.mkForce [ "${base}/fluent-bit" ];
      # Security hardening
      UMask = "077";
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      PrivateMounts = true;
      ProtectHome = true;
      PrivateTmp = true;
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      # ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RemoveIPC = true; # Remove IPC objects when unit is stopped
      RestrictNamespaces = "yes";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = "@system-service";
      SystemCallArchitectures = "native";
      ## Proc filesystem
      ProcSubset = "pid";
      ProtectProc = "invisible";
      # Needs network access
      PrivateNetwork = false;
      # End Security hardening
    };

    services.fluent-bit = {
      enable = true;
      settings = {
        pipeline = {
          inputs = [
            {
              name = "systemd";
              tag = "systemd.*";
              db = "${base}/fluent-bit/fluent-bit-systemd.db";
              read_from_tail = true;
            }
          ];
          filters = [
            {
              name = "modify";
              match = "systemd.*";
              Rename = [
                "_SYSTEMD_UNIT unit"
                "_HOSTNAME hostname"
              ];
              Remove = [
                "_MACHINE_ID"
                "_PID"
                "_UID"
                "_GID"
                "_CAP_EFFECTIVE"
                "_SYSTEMD_INVOCATION_ID"
                "_SYSTEMD_CGROUP"
                "_SYSTEMD_SLICE"
                "_SYSTEMD_SESSION"
                "_SYSTEMD_OWNER_UID"
                "_SYSTEMD_OWNER_GID"
                "_SYSTEMD_USER_UNIT"
                "_SYSTEMD_USER_SLICE"
                "_SYSTEMD_USER_SESSION"
                "CONTAINER_LOG_EPOCH"
                "CONTAINER_LOG_ORDINAL"
                "CONTAINER_ID_FULL"
              ];
            }
          ];
          outputs = [
            {
              name = "loki";
              host = config.custom.vars.serverIp;
            }
          ];
        };
        service = {
          grace = 30;
        };
      };
    };
  };
}
