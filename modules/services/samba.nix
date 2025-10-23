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
    invalidUsers = [
      "root"
    ];
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
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
}
