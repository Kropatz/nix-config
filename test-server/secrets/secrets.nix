let
  nix-test-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVqEb1U1c9UX3AF8otNyYKpIUMjc7XSjZY3IkIPGOqi root@server";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUA7uVKXAF2UcwaIDSJP2Te8Fi++2zkKzSPoRx1vQrI root@server";
  systems = [ nix-test-vm server ];
in
{
  "github-runner-token.age".publicKeys = [ nix-test-vm server ];
  "github-runner-pw.age".publicKeys = [ nix-test-vm server ];
  "duckdns.age".publicKeys = [ nix-test-vm server ];
  "nextcloud-admin.age".publicKeys = [ nix-test-vm server ];
  "restic-pw.age".publicKeys = [ nix-test-vm server ];
}
