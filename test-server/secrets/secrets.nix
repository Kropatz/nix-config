let
  nix-test-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVqEb1U1c9UX3AF8otNyYKpIUMjc7XSjZY3IkIPGOqi root@server";
  systems = [ nix-test-vm ];
in
{
  "github-runner-token.age".publicKeys = [ nix-test-vm ];
  "github-runner-pw.age".publicKeys = [ nix-test-vm ];
  "duckdns.age".publicKeys = [ nix-test-vm ];
  "nextcloud-admin.age".publicKeys = [ nix-test-vm ];
}