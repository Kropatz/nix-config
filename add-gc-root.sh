#!/usr/bin/env bash
GCROOT_DIR="/nix/var/nix/gcroots/my-configs"
sudo mkdir -p "$GCROOT_DIR"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for host in server-vm amd-server amd-server-exposed-vm amd-server-vpn-vm; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --out-link "$TMP/$host"
done
sudo cp -r "$TMP"/* "$GCROOT_DIR"
