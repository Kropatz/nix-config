# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  keepassWithPlugins = pkgs.keepass.override {
    plugins = [
      pkgs.keepass-keepassrpc
    ];
  };

in

{
  imports =
    [ # Include the results of the hardware scan.
	./hardware-configuration.nix
	./modules/battery.nix
	./modules/ssh.nix
	#./modules/wireguard.nix
	## -- set in flake.nix
	#<nixos-hardware/dell/xps/15-7590/nvidia>
	#<home-manager/nixos>
    ];

  # storage optimization
  nix.optimise.automatic = true;

  services.auto-cpufreq.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-laptop-no-gpu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.extraHosts =
  ''
    82.218.12.28 kopatz.ddns.net
  '';

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  #users.mutableUsers=false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kopatz = {
    isNormalUser = true;
    description = "kopatz";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    #password = "test";
    packages = with pkgs; [
	#firefox
    #  thunderbird
      discord
      librewolf
      ungoogled-chromium
    ];
  };

    # home manager
  #home-manager.useGlobalPkgs = true;

 # home-manager.users.kopatz = { pkgs, ... }: {

    # The state version is required and should stay at the version you
    # originally installed.
  #  system.stateVersion = "23.05";
  #};

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.kdeconnect.enable = true;

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    nerdfonts
    #font-awesome
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    wget
    nixos-option
    kate
    keepassWithPlugins
    jetbrains.idea-ultimate
    jetbrains.rider
    dotnet-sdk_7
    dotnet-runtime_7
    neovim
    htop
    btop
    git
    xfce.thunar
    killall
    xclip
    usbutils
    bun
    inputs.agenix.packages."x86_64-linux".default
    insomnia
    remmina
    nextcloud-client
    #podman-compose
    #arion # docker
    neofetch
    thunderbird
    rofi
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  };

  ### docker
  virtualisation.docker.enable = true;

  ## podman
  #virtualisation = {
  #  podman = {
  #    enable = false;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      #dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
  #    defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
      #defaultNetwork.settings = {
      #  dns_enabled = true;
      #};
   # };
  #};

  systemd.tmpfiles.rules = [
    "d /docker-data 0755 kopatz users"
  ];

  #virtualisation.oci-containers.containers.mssql = {
  #  image = "mcr.microsoft.com/mssql/server:2022-latest";
  #  volumes = [ "/docker-data/mssql/data:/var/opt/mssql/data" ];
  #  environment = {
  #    ACCEPT_EULA = "Y";
  #    MSSQL_SA_PASSWORD="ufhaiufhashfshfklslwkhebwejhvtjhqwvrhp23508v3z8pt";
  #  };
  #};

  #module = [ arion.nixosModules.arion ];
  #virtualisation.arion = {
  #  backend = "docker";
  #  projects.mssql.settings = {
  #    services.mssql.service = {
  #      image = "mcr.microsoft.com/mssql/server:2022-latest";
  #      restart = "unless-stopped";
  #      #volumes = { /docker-data/mssql/data:/var/opt/mssql/data; };
  #      environment = { ACCEPT_EULA = "Y"; MSSQL_SA_PASSWORD="ufhaiufhashfshfklslwkhebwejhvtjhqwvrhp23508v3z8pt"; };
  #    };
  #  };
  #};

  ### end docker

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
