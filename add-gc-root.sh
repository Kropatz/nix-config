#!/usr/bin/env bash
set -e
# Other hosts are built into the HDD chroot store, so their GC roots belong to *that*
# store rather than the SSD one. See docs/hdd-store.md.
STORE="${NIX_HDD_STORE:-/data/nix-store}"
GCROOT_DIR="$STORE/nix/var/nix/gcroots/my-configs"

# /data is mounted nofail: without this guard a missing HDD silently builds a fresh
# store onto the root filesystem.
mountpoint -q /data || {
  echo "/data is not mounted - refusing to build onto the SSD" >&2
  exit 1
}

mkdir -p "$GCROOT_DIR"

for host in server-vm amd-server amd-server-exposed-vm amd-server-vpn-vm; do
  path=$(nix build --store "$STORE" \
    ".#nixosConfigurations.$host.config.system.build.toplevel" \
    --no-link --print-out-paths)
  # Must be the virtual /nix/store path; a link into "$STORE/nix/store/..." is ignored.
  ln -sfn "$path" "$GCROOT_DIR/$host"
done

# These links look dangling to ls (the virtual target isn't on the SSD) but are live:
nix-store --store "$STORE" --gc --print-roots | grep my-configs
