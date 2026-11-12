#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# !nix-shell -i bash -p sbomnix jq
set -e
OUT_DIR="sbom"
mkdir -p "$OUT_DIR"

# These hosts are built into the HDD chroot store, so sbomnix has to look there.
# NIX_REMOTE redirects the nix calls sbomnix makes internally. Exported here rather
# than in the shebang so nix-shell itself still resolves jq against the SSD store.
# See docs/hdd-store.md.
if mountpoint -q /data; then
  export NIX_REMOTE="${NIX_HDD_STORE:-/data/nix-store}"
else
  echo "/data is not mounted - refusing to build onto the SSD" >&2
  exit 1
fi

# sbomnix >= 1.9 reads nixpkgs metadata via builtins.getFlake "path:<flake source>".
# Nix 2.35 no longer copies the local flake source into the store on eval, so that path
# doesn't exist and sbomnix logs "package_meta.nix scan failed" and drops licenses,
# homepages etc. Archiving puts the source (and inputs) into the store first.
nix flake archive . >/dev/null

for host in server-vm amd-server amd-server-exposed-vm amd-server-vpn-vm; do
  mkdir -p "$OUT_DIR/$host"
  sbomnix .#nixosConfigurations.$host.config.system.build.toplevel \
    --csv "$OUT_DIR/$host/sbom.csv" \
    --cdx "$OUT_DIR/$host/sbom.cdx.json" \
    --spdx "$OUT_DIR/$host/sbom.spdx.json"
  # set systemd version to avoid unecessary CVE entries in DTrack
  systemdVersion=$(cat "$OUT_DIR/$host/sbom.cdx.json" | jq '.components.[] | select(."bom-ref" | test("systemd-\\d+")) | ."bom-ref"' | sed 's/.*systemd-//' | sed 's/"//g' | sed 's/.drv//')
  jq --arg ver "$systemdVersion" '
    (.components[] | select(.name == "systemd"))
    |= (.cpe |= gsub("systemd::"; "systemd:\($ver):") | .version = $ver)
  ' "$OUT_DIR/$host/sbom.cdx.json" >tmp.json && mv tmp.json "$OUT_DIR/$host/sbom.cdx.json"
done
