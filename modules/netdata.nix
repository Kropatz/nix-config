{
  networking.firewall.allowedTCPPorts = [ 19999 ];
  services.netdata = {
    enable = true;
    configText = ''
      [global]
      update every = 2

      [web]
      default port = 19999
      bind to = 192.168.0.6 192.168.2.1
      allow connections from = localhost 192.168.0.* 192.168.2.*

      [db]
      # number of tiers used (1 to 5, 3 being default)
      storage tiers = 3

      # Tier 0, per second data
      dbengine multihost disk space MB = 256

      # Tier 1, per minute data
      dbengine tier 1 multihost disk space MB = 128
      dbengine tier 1 update every iterations = 60

      # Tier 2, per hour data
      dbengine tier 2 multihost disk space MB = 64
      dbengine tier 2 update every iterations = 60

      [logs]
      error = syslog

      [plugins]
      timex = no
      idlejitter = no
      # netdata monitoring = yes
      tc = no
      # diskspace = yes
      # proc = yes
      # cgroups = yes
      statsd = no
      #enable running new plugins = yes
      #check for new plugins every = 60
      slabinfo = no
      nfacct = no
      charts.d = no
      python.d = no
      go.d = no
      ioping = no
      perf = no
      freeipmi = no
      apps = yes
      '';
  };
}
