 {
  services.adguardhome = {
    enable = true;
    settings = {
      users = [
        {
          name = "admin";
          password = "$2y$15$3RPgWOXmeUU6NGo.XTx2LuL1oKS.YRrLOIa9VmINnzvtkHNY7A4hq";
        }
      ];
      dns = {
        bind_hosts = [ "127.0.0.1" ];
        port = 53;
        protection_enabled = true;
        filtering_enabled = true;
        upstream_dns = [ "quic://doh.tiar.app" "tls://getdnsapi.net"];
        use_http3_upstreams = true;
      };
      querylog = {
        enabled = false;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "adguard dns list";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "adguard block list";
          id = 2;
        }
        {
          enabled = true;
          url = "https://dbl.oisd.nl/";
          name = "big block list";
          id = 3;
        }
      ];
      dhcp = { enabled = false; };
      dhcpv6 = { enabled = false; };
      tls = {
        enabled = true;
      };
    };
  };
}
