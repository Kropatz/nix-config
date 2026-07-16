#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# !nix-shell -i bash -p sbomnix jq
set -e
OUT_DIR="sbom"
mkdir -p "$OUT_DIR"

for host in server-vm amd-server amd-server-exposed-vm amd-server-vpn-vm; do
  mkdir -p "$OUT_DIR/$host"
  sbomnix .#nixosConfigurations.$host.config.system.build.toplevel \
    --csv "$OUT_DIR/$host/sbom.csv" \
    --cdx "$OUT_DIR/$host/sbom.cdx.json" \
    --spdx "$OUT_DIR/$host/sbom.spdx.json"
  # set systemd version to avoid unecessary CVE entries in DTrack
  systemdVersion=$(cat "$OUT_DIR/$host/sbom.cdx.json" | jq '.components.[] | select(.name | test("systemd-\\d+")) | .name' | sed 's/systemd-//' | sed 's/"//g')
  jq --arg ver "$systemdVersion" '
  (.components[] | select(.name == "systemd") | .version) = $ver |
  (.components[] | select(.name == "systemd") | .cpe) |= gsub("systemd::"; "systemd:\($ver):")
' "$OUT_DIR/$host/sbom.cdx.json" >tmp.json && mv tmp.json "$OUT_DIR/$host/sbom.cdx.json"
done
