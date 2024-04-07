let
  kop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 lukas@Kopatz-PC2";
  nix-test-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVqEb1U1c9UX3AF8otNyYKpIUMjc7XSjZY3IkIPGOqi root@server";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUA7uVKXAF2UcwaIDSJP2Te8Fi++2zkKzSPoRx1vQrI root@server";
  users = [ kop ];
  systems = [ nix-test-vm server ];
in
{
  "github-runner-token.age".publicKeys = [ nix-test-vm server kop ];
  "github-runner-pw.age".publicKeys = [ nix-test-vm server kop ];
  "duckdns.age".publicKeys = [ nix-test-vm server kop ];
  "nextcloud-admin.age".publicKeys = [ nix-test-vm server kop ];
  "nextcloud-cert.age".publicKeys = [ nix-test-vm server kop ];
  "nextcloud-key.age".publicKeys = [ nix-test-vm server kop ];
  "restic-pw.age".publicKeys = [ nix-test-vm server kop ];
  "restic-s3.age".publicKeys = [ nix-test-vm server kop ];
  "restic-gdrive.age".publicKeys = [ nix-test-vm server kop ];
  "wireguard-private.age".publicKeys = [ nix-test-vm server kop ];
  "coturn-secret.age".publicKeys = [ nix-test-vm server kop ];
  "matrix-registration.age".publicKeys = [ nix-test-vm server kop ];
  "paperless.age".publicKeys = [ nix-test-vm server kop ];
  "kavita.age".publicKeys = [ nix-test-vm server kop ];
  "step-ca-pw.age".publicKeys = [ nix-test-vm server kop ];
  "step-ca-key.age".publicKeys = [ nix-test-vm server kop ];
  "syncthing-key.age".publicKeys = [ server kop ];
  "syncthing-cert.age".publicKeys = [ server kop ];
}
