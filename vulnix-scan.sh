#!/usr/bin/env bash
set -euo pipefail
# Scan a host's runtime closure from the HDD store's GC roots (see add-gc-root.sh)
# with vulnix. The host is picked with fzf unless given as the first argument.
# Remaining arguments are passed through to vulnix, e.g. --json.
#   ./vulnix-scan.sh [host] [vulnix args...]
# See docs/hdd-store.md.
STORE="${NIX_HDD_STORE:-/data/nix-store}"
GCROOT_DIR="/nix/var/nix/gcroots/my-configs"

# /data is mounted nofail: without this guard vulnix would scan an empty directory.
mountpoint -q /data || {
  echo "/data is not mounted" >&2
  exit 1
}

# Never sudo this: root opening the HDD store flips its permissions.
if ((EUID == 0)); then
  echo "do not run as root - it breaks the HDD store's permissions" >&2
  exit 1
fi

if [[ $# -gt 0 && $1 != -* ]]; then
  host=$1
  shift
  [[ -L "$STORE$GCROOT_DIR/$host" ]] || {
    echo "no GC root for '$host' in $STORE$GCROOT_DIR" >&2
    exit 1
  }
else
  host=$(find "$STORE$GCROOT_DIR" -mindepth 1 -maxdepth 1 -type l -printf '%f\n' \
    | sort | fzf --prompt="vulnix> " --height=40% --reverse) || exit 0
fi

if command -v vulnix >/dev/null; then
  vulnix=(vulnix)
else
  vulnix=(nix run nixpkgs#vulnix --)
fi

# vulnix resolves the path inside the guest root, so pass the in-store root path,
# not "$STORE/..." (it would get the guest prefix twice).
exec "${vulnix[@]}" --guest "$STORE" --closure "$GCROOT_DIR/$host" "$@"
