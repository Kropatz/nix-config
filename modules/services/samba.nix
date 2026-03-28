{
  #services.samba-wsdd = {
  #  enable = true;
  #  openFirewall = true;
  #};

  users.users.franz = {
    isNormalUser = true;
    home = "/home/franz";
    hashedPassword = "$y$j9T$opts2crrOHbRzHsFzOh/S1$LU3zmC4tKOw43THlOSw6qDXPse.l1ZvcxolN3EP7/ED";
  };

  # add user to samba with smbpasswd -a
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "invalid users" = ["root"];
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "franz" = {
        "path" = "/hdd/shares/franz";
        "valid users" = "franz";
        "public" = "no";
        "writable" = "yes";
        "printable" = "no";
      };
    };
  };

  systemd.services = {
    samba-nmbd.serviceConfig = {
      # hardening
      InaccessiblePaths = [
        "-/data"
        "-/1tbssd"
        "-/hdd/data"
      ];
      CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateTmp = "disconnected";
      PrivateDevices = true;
      PrivateMounts = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectProc = "ptraceable";
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectClock = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      SocketBindDeny = [
        # "ipv4:udp"
        # "ipv6:udp"
        # "ipv6:tcp"
      ];
      RestrictNamespaces = "yes";
    };
    samba-smbd.serviceConfig = {
      # hardening
      InaccessiblePaths = [
        "-/data"
        "-/1tbssd"
        "-/hdd/data"
      ];
      CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateDevices = true;
      PrivateMounts = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectClock = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      SocketBindDeny = [
        "ipv4:udp"
        "ipv6:udp"
      ];
      RestrictNamespaces = "yes";
    };
    samba-winbindd.serviceConfig = {
      # hardening
      InaccessiblePaths = [
        "-/data"
        "-/1tbssd"
        "-/hdd/data"
      ];
      CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
      ProtectSystem = "full";
      ProtectHome = true;
      PrivateDevices = true;
      PrivateMounts = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectProc = "ptraceable";
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectClock = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_NETLINK"
      ];
      SocketBindDeny = [
        "ipv4:udp"
        "ipv4:tcp"
        "ipv6:udp"
        "ipv6:tcp"
      ];
      RestrictNamespaces = "yes";
    };
  };

}
