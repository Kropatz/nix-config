{ config, pkgs, ... }:

{

  # Better scheduling for CPU cycles - thanks System76!!!
  services.system76-scheduler.settings.cfsProfiles.enable = true;

  services.upower.enable = true;
  environment.systemPackages = with pkgs; [ gnome-power-manager ];

  # Enable TLP (better than gnomes internal power manager)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      #CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      #Optional helps save long term battery health
      #START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

    };
  };

  # Disable GNOMEs power management
  services.power-profiles-daemon.enable = false;

  # Enable powertop
  #powerManagement.powertop.enable = true;

  # Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = true;

  # toggle tlp off if this is on
  #  services.auto-cpufreq.enable = true;
}
