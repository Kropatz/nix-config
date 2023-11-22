{
  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.0.0/16"
    ];
    bantime = "24h";
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
  };
}
