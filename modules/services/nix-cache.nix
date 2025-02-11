{ config, ... }: {

  age.secrets.binary-cache = {
    file = ../../secrets/binary-cache.age;
  };
  nix.sshServe = {
    enable = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 kopatz"
    ];
  };
  services.nix-serve = {
    enable = true;
    openFirewall = true;
    port = 5000;
    secretKeyFile = config.age.secrets.binary-cache.path;
  };
}
