{pkgs, lib, config, ...}:
{
  # Run tailscale up --login-server http://<headscale_server>
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
