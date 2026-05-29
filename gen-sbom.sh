#!/usr/bin/env nix-shell
#!nix-shell -i bash -p sbomnix
OUT_DIR="sbom"
mkdir -p "$OUT_DIR"

for host in server-vm amd-server amd-server-exposed-vm amd-server-vpn-vm; do
  mkdir -p "$OUT_DIR/$host"
  sbomnix .#nixosConfigurations.$host.config.system.build.toplevel \
     --csv  "$OUT_DIR/$host/sbom.csv" \
     --cdx  "$OUT_DIR/$host/sbom.cdx.json" \
     --spdx "$OUT_DIR/$host/sbom.spdx.json"
done
