{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  custom = {
    nftables.enable = true;
    nix = {
      settings.enable = true;
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMypKJQvn68s8iNk9J9zghFlW4nrd03FwqfvGQ9sAmWojXe6pKrkat++8grIfB60aiIwNjHeXigVdZrpIb0QiR7+maPLPtxySTmgD7GeyAbwJrAymgKAzJcQvq5tKHtjH60KhLe4QzGXXpjoGIhl/8FhepRT6306JE8OfMwBUwOa3wcEdeJ7eK4JZdELCne3Gj16eWHy8iNIQswNtvJ70M7RACyDJARuazde3zFqkRYCP9Rqinegg/DVd+ykC2qHqM/yCersCOGn+I3hPCS1tz/AhDTQ7T9A7j5CLjv6ZbRS+B7a7u7z5qOAla468sELaiAEo2+fovlh8kib5zzWM2pK3rSEfUzFVGAAfHtrdR8pYynl3DBNC5XGzDT8xqa4B/qJIRoPmr8CMroLBOGGZQm9TJbmhfl8vT96RUwOA6qUmLQl6b0qJRRMkvlgCvKZyZ3d6pPfizQigTn1evBveqO9dgGcCAyAi0Ob6JZisTWUn5nAqe7CR1h2EKC0lqdCc="
  ];

  system.stateVersion = "23.11";
}