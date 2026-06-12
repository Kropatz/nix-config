let
  kop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 lukas@Kopatz-PC2";
  kop-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx2xf3EM/FIlOOPdFof/iLK9vw+g5IY/xjZFoig+n9R root@kop-pc";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUA7uVKXAF2UcwaIDSJP2Te8Fi++2zkKzSPoRx1vQrI root@server";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrNYiH1Z05Ms01tDScPb4GbeNo7vTnSNXYcDQuDKnbs root@framework";
  server-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGsTZvAahTrszYDHn+94sLtcF8865/mpd26ZDVQklSj root@server-vm"; # actual used server
  mini-pc-proxmox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0kX32LfIOv8FDVvdp7lWesVvMGh5tj84nv7TkIR1cs root@mini-pc";
  amd-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/t25OaQF020DZdew53gMFqoeHX1+g3um02mopke2eX root@nixos";
  amd-server-vpn-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKkTbNz36z1gGbKp+7NyyTpMslXcFLX0tOrfJ/GQFn+g root@amd-server-vpn-vm";
  amd-server-exposed-vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLYGX4eMZzIAlI41vvNTgyVikHHW7ygd6+D3yp/pIjU root@amd-server-exposed-vm";
  users = [ kop ];
  systems = [
    server-vm
    server
    laptop
  ];
in
{
  "github-runner-token.age".publicKeys = [
    server-vm
    kop
  ];
  "github-runner-pw.age".publicKeys = [
    server-vm
    kop
  ];
  "duckdns.age".publicKeys = [
    server-vm
    kop
  ];
  "nextcloud-admin.age".publicKeys = [
    server-vm
    kop
  ];
  "nextcloud-cert.age".publicKeys = [
    server-vm
    kop
  ];
  "nextcloud-key.age".publicKeys = [
    server-vm
    kop
  ];
  #backups
  "restic-pw.age".publicKeys = [
    server-vm
    kop
  ];
  "restic-s3.age".publicKeys = [
    server-vm
    kop
  ];
  "restic-gdrive.age".publicKeys = [
    server-vm
    kop
  ];
  "restic-internxt.age".publicKeys = [
    server-vm
    kop
  ];
  "wireguard-private.age".publicKeys = [
    server-vm
    kop
  ];
  "wireguard-client.age".publicKeys = [
    kop
    laptop
  ];
  "coturn-secret.age".publicKeys = [
    server-vm
    kop
  ];
  "matrix-registration.age".publicKeys = [
    server-vm
    kop
  ];
  "paperless.age".publicKeys = [
    server-vm
    kop
  ];
  "kavita.age".publicKeys = [
    server-vm
    amd-server-exposed-vm
    kop
  ];
  "step-ca-pw.age".publicKeys = [
    server-vm
    kop
  ];
  "step-ca-key.age".publicKeys = [
    server-vm
    kop
  ];
  "grafana-contact-points.age".publicKeys = [
    server-vm
    kop
  ];
  "grafana-pw.age".publicKeys = [
    server-vm
    kop
  ];
  "fileshelter-conf.age".publicKeys = [
    server-vm
    kop
  ];
  "webhook.age".publicKeys = [
    server-vm
    server
    kop
    amd-server
  ];
  "stash-auth.age".publicKeys = [
    server-vm
    kop
  ];
  "radicale.age".publicKeys = [
    server-vm
    kop
  ];
  "binary-cache.age".publicKeys = [
    kop
    amd-server
  ];
  "wireguard-evo-vpn.age".publicKeys = [
    kop
    amd-server-vpn-vm
  ];
  "cloudflare-api.age".publicKeys = [
    kop
    server-vm
  ];
  "cloudflare-api-env.age".publicKeys = [
    kop
    server-vm
  ];
  "git-mail-pw.age".publicKeys = [
    kop
    server-vm
  ];
  "gitea-runner-token.age".publicKeys = [
    kop
    server-vm
  ];
  "netbird-conf.age".publicKeys = [
    kop
    server-vm
  ];
  "samba-exposedvm.age".publicKeys = [
    kop
    amd-server-exposed-vm
  ];
  "samba-jakob-nas.age".publicKeys = [
    kop
    server-vm
  ];
  "discord-token-sanitizer.age".publicKeys = [
    kop
    amd-server-exposed-vm
  ];
  "robot-email-pw.age".publicKeys = [
    kop
    kop-pc
  ];
  "ente-config.age".publicKeys = [
    kop
    amd-server-exposed-vm
  ];
}
