{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird-client";
  cfg = config.custom.services.${name};
in
{

  # HOWTO: Enable config, then run netbird-wt0 up --management-url https://netbird.kopatz.dev --setup-key <setup-key>
  config = lib.mkIf cfg.enable {
    services.netbird.clients.wt0 = {

      # Automatically login to your Netbird network with a setup key
      # This is mostly useful for server computers.
      # For manual setup instructions, see the wiki page section below.
      login = {
        enable = false;

        # Path to a file containing the setup key for your peer
        # NOTE: if your setup key is reusable, make sure it is not copied to the Nix store.
        setupKeyFile = "/path/to/your/setup-key";
      };

      # Port used to listen to wireguard connections
      port = 51821;

      logLevel = "error";

      # Set this to true if you want the GUI client
      ui.enable = false;

      # This opens ports required for direct connection without a relay
      openFirewall = true;

      # This opens necessary firewall ports in the Netbird client's network interface
      openInternalFirewall = true;
    };
  };
}
