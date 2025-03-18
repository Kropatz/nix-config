{ pkgs, config, lib, ... }:
# idk, dont need this
with lib;
let
  cfg = config.custom.services.kubernetes;
in
{
  options.custom.services.kubernetes = {
    enable = mkEnableOption "Enables kubernetes";
  };
  config =
    let
      kubeMasterIP = "localhost";
      kubeMasterHostname = "localhost";
    in
    lib.mkIf cfg.enable {

      networking.firewall.allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];
      networking.firewall.allowedUDPPorts = [
        # 8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];
      services.k3s.enable = true;
      services.k3s.role = "server";
      services.k3s.extraFlags = toString [
        # "--kubelet-arg=v=4" # Optionally add additional args to k3s
      ];
      environment.systemPackages = with pkgs; [
        k3s
      ];
      #services.kubernetes = {
      #  roles = ["master" "node"];
      #  masterAddress = "localhost";
      #  apiserverAddress = "https://localhost:6443";
      #  apiserver = {
      #    advertiseAddress = "127.0.0.1";
      #    securePort = 6443;
      #    allowPrivileged = true;
      #  };
      #};
    };
}
