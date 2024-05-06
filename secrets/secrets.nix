let
  kop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 lukas@Kopatz-PC2";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUA7uVKXAF2UcwaIDSJP2Te8Fi++2zkKzSPoRx1vQrI root@server";
  mini-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKla9+Gj2i9Ax7cIdnTM6zsmze3g1N/qCPqhga0P+toU root@mini-pc";
  users = [ kop ];
  systems = [ mini-pc server ];
in
{
  "github-runner-token.age".publicKeys = [ mini-pc server kop ];
  "github-runner-pw.age".publicKeys = [ mini-pc server kop ];
  "duckdns.age".publicKeys = [ mini-pc server kop ];
  "nextcloud-admin.age".publicKeys = [ mini-pc server kop ];
  "nextcloud-cert.age".publicKeys = [ mini-pc server kop ];
  "nextcloud-key.age".publicKeys = [ mini-pc server kop ];
  "restic-pw.age".publicKeys = [ mini-pc server kop ];
  "restic-s3.age".publicKeys = [ mini-pc server kop ];
  "restic-gdrive.age".publicKeys = [ mini-pc server kop ];
  "wireguard-private.age".publicKeys = [ mini-pc server kop ];
  "wireguard-client.age".publicKeys = [ kop ];
  "coturn-secret.age".publicKeys = [ mini-pc server kop ];
  "matrix-registration.age".publicKeys = [ mini-pc server kop ];
  "paperless.age".publicKeys = [ mini-pc server kop ];
  "kavita.age".publicKeys = [ mini-pc server kop ];
  "step-ca-pw.age".publicKeys = [ mini-pc server kop ];
  "step-ca-key.age".publicKeys = [ mini-pc server kop ];
  "grafana-contact-points.age".publicKeys = [ mini-pc server kop ];
  "fileshelter-conf.age".publicKeys = [ mini-pc server kop ];
}
