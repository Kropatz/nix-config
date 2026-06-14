{
  config,
  lib,
  pkgs,
  ...
}:

let
  # --- Blocklist sources ---
  # Add or remove URLs here. Each must be a plain list of IPs or CIDRs (one per line).
  # Comments (#) and blank lines are stripped automatically.
  blocklistSources = [
    # DShield top attacking subnets (SANS ISC) — tab-separated: IP / mask / CIDR prefix
    "https://feeds.dshield.org/block.txt"
    # blocklist.de — scanners, bots, brute-force, scrapers
    "https://lists.blocklist.de/lists/all.txt"
    # GreenSnow — bots and port scanners
    "https://blocklist.greensnow.co/greensnow.txt"
    # Spamhaus DROP — hijacked netblocks used by cybercrime operations
    "https://www.spamhaus.org/drop/drop.txt"
    # FireHOL level2 — 48-hour attack tracker, pre-merged CIDRs (good all-rounder)
    "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset"
  ];

  # nftables table and set names — must match your existing nftables config
  nftTable = "inet ip_drop";
  nftSet = "blocked-ip4";

  # How often to refresh (systemd calendar format)
  refreshInterval = "hourly"; # every 4 hours

  # --- The updater script ---
  # Written as a pkgs.writeShellApplication so nix handles the PATH / dependencies.
  updaterScript = pkgs.writeShellApplication {
    name = "nft-blocklist-update";

    runtimeInputs = with pkgs; [
      curl
      gawk
      iproute2 # provides 'ip' for basic sanity; not strictly needed but good to have
      nftables # provides 'nft'
      coreutils
    ];

    text = ''
      set -euo pipefail

      NFT_TABLE="${nftTable}"
      NFT_SET="${nftSet}"

      TMPFILE=$(mktemp /tmp/nft-blocklist-XXXXXX.txt)
      trap 'rm -f "$TMPFILE"' EXIT

      echo "[blocklist] Fetching sources..."

      # --- Per-source fetch + normalise ---
      # Each source may use a different format; we normalise to bare CIDRs.
      fetch_and_normalise() {
        local url="$1"
        curl --silent --fail --max-time 30 --retry 3 "$url" | \
          awk '
            # Skip blank lines and comment lines
            /^[[:space:]]*$/ { next }
            /^[[:space:]]*#/ { next }

            # DShield format: "IP<tab>netmask<tab>prefix ..." — convert to CIDR
            /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[[:space:]]+[0-9]+/ {
              print $1 "/" $3
              next
            }

            # Plain CIDR (e.g. 1.2.3.0/24) — pass through
            /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+/ {
              print $1
              next
            }

            # Plain host IP (no prefix) — treat as /32
            /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {
              print $1 "/32"
              next
            }
          '
      }

      # Fetch all sources into the temp file, skip on individual failure
      ${lib.concatMapStringsSep "\n" (url: ''
        echo "[blocklist] Fetching: ${url}"
        fetch_and_normalise "${url}" >> "$TMPFILE" || \
          echo "[blocklist] WARNING: failed to fetch ${url}, skipping" >&2
      '') blocklistSources}
      echo "74.7.227.136/32" >> "$TMPFILE"

      # Deduplicate lines (nft auto-merge handles overlapping CIDRs at load time)
      sort -u "$TMPFILE" -o "$TMPFILE"

      TOTAL=$(wc -l < "$TMPFILE")
      echo "[blocklist] Total entries after dedup: $TOTAL"

      if [ "$TOTAL" -eq 0 ]; then
        echo "[blocklist] ERROR: no entries fetched — aborting to avoid flushing the set" >&2
        exit 1
      fi

      # Build the nft element string: "1.2.3.0/24, 5.6.7.8/32, ..."
      ELEMENTS=$(paste -sd ',' "$TMPFILE")

      echo "[blocklist] Loading into nft set $NFT_TABLE / $NFT_SET ..."

      # Atomic-ish update: flush then reload inside a single nft transaction
      nft -f - <<EOF
      flush set $NFT_TABLE $NFT_SET
      add element $NFT_TABLE $NFT_SET { $ELEMENTS }
      EOF

      echo "[blocklist] Done. $TOTAL entries active."
    '';
  };

in
{
  # -------------------------------------------------------------------------
  # systemd one-shot service that runs the updater
  # -------------------------------------------------------------------------
  systemd.services.nft-blocklist-update = {
    description = "Update nftables IP blocklist (scanners / bots / scrapers)";
    after = [
      "network-online.target"
      "nftables.service"
    ];
    wants = [ "network-online.target" ];
    # Also run once at boot (after nftables is up) so the set is populated immediately
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe updaterScript;
      # Run as root — required to call nft
      User = "root";
      # Basic hardening
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      # Allow writing only to /tmp (via PrivateTmp)
      ReadWritePaths = [ ];
    };
  };

  # -------------------------------------------------------------------------
  # systemd timer — fires on the configured interval
  # -------------------------------------------------------------------------
  systemd.timers.nft-blocklist-update = {
    description = "Periodically refresh nftables IP blocklist";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = refreshInterval;
      # Spread the start time by up to 5 min to avoid thundering-herd
      RandomizedDelaySec = "5m";
      Persistent = true; # catch up if the machine was off
    };
  };

  # -------------------------------------------------------------------------
  # nftables — make sure the table + set exist so the updater can populate them
  # This merges with whatever other rules you already have.
  # -------------------------------------------------------------------------
  networking.nftables.tables.ip_drop = {
    family = "inet";
    content = ''
      set blocked-ip4 {
        typeof ip saddr
        flags interval
        auto-merge
        # starts empty; nft-blocklist-update.service fills it at boot + every 4h
        elements = { 45.144.212.240, 74.7.227.136 }
      }

      chain input {
        type filter hook input priority -100; policy accept;
        ip saddr @blocked-ip4 log prefix "nftables drop: " level info counter drop
      }

      chain forward {
        type filter hook forward priority -100; policy accept;
        ip saddr @blocked-ip4 drop
      }
    '';
  };

  # Make the script available on PATH for manual runs: nft-blocklist-update
  environment.systemPackages = [ updaterScript ];
}
