{
  #services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  #networking.firewall.allowedTCPPorts = [
  #5357 # wsdd
  #];
  #networking.firewall.allowedUDPPorts = [
  #3702 # wsdd
  #];
  services.samba.openFirewall = true;
  services.samba = {
    enable = true;
    securityType = "user";
    invalidUsers = [
      "root"
    ];
    extraConfig = ''
      	    disable netbios = yes
      	    smb ports = 445
                  workgroup = WORKGROUP
                  server string = smbnix
                  security = user 
                  #use sendfile = yes
                  #max protocol = smb2
                  # note: localhost is the ipv6 localhost ::1
                  hosts allow = 192.168.0. 192.168.174.1 127.0.0.1 localhost
                  hosts deny = 0.0.0.0/0
                  guest account = nobody
                  map to guest = bad user
    '';
    shares = {
      homes = {
        browseable = "no";
        writable = "yes";
      };
    };
  };
}
