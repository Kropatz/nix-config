# Building on the HDD

`kop-pc` has a NVMe (`/`, holds `/nix/store`) and a spinning disk at `/data`.
Configs for *other* hosts have no reason to occupy the SSD: their store paths are garbage
locally the moment they're deployed. So they get built into a second Nix store on the HDD:

    /data/nix-store

This is a **chroot store**: Nix keeps `storeDir` as `/nix/store` and only redirects the
*physical* location to `/data/nix-store/nix/store`. Path hashes are therefore identical to
`cache.nixos.org`, so substitution works normally — nothing rebuilds from source.

`/data` is owned by `kopatz`, so all of this runs **without sudo** and bypasses the
nix-daemon entirely.

## Two ways to select the store

| Form | Use when |
| --- | --- |
| `nix build --store /data/nix-store …` | Driving `nix` directly. |
| `NIX_REMOTE=/data/nix-store <cmd>` | Wrapper tools (`deploy`, `sbomnix`) that shell out to `nix` internally. |

`NIX_REMOTE` sets the *default* store for every nix invocation in that process tree, which
is what makes deploy-rs and sbomnix work unmodified.

Do **not** add `--eval-store auto`. It speeds up evaluation by reusing already-cached flake
inputs, but writes `.drv`s and flake sources back to the SSD.

## Other hosts — fully on the HDD

Aliases (see `modules/opt-impl/home-manager/zsh/default.nix`):

    buildHdd .#nixosConfigurations.amd-server.config.system.build.toplevel
    deployRebuildHdd root@192.168.0.20 --flake .#amd-server
    gcHdd                           # collect garbage in the HDD store
    optimiseHdd                     # hardlink-dedupe the HDD store

**deploy-rs cannot build into the HDD store** — see the section below.

Manual deploy without deploy-rs:

    p=$(nix build --store /data/nix-store \
      .#nixosConfigurations.amd-server.config.system.build.toplevel \
      --no-link --print-out-paths)
    nix copy --from /data/nix-store --to ssh://root@192.168.0.20 "$p"
    ssh root@192.168.0.20 "$p/bin/switch-to-configuration switch"

### deploy-rs is incompatible with the HDD store

`NIX_REMOTE=/data/nix-store deploy .#<node>` fails with an unhelpful message:

    [ERROR] Failed to build profile on node amd-server-vpn-vm: amd-server-vpn-vm

The `nix build` actually **succeeds** — the path lands in the HDD store. What fails is the
sanity check immediately after it, at `src/push.rs:189` and `:201`, which stats two files
inside the built profile:

    if !Path::new(format!("{}/deploy-rs-activate", ...)).exists() { return Err(...) }
    if !Path::new(format!("{}/activate-rs",       ...)).exists() { return Err(...) }

`activatable-nixos-system-*` is a **symlink farm** whose entries point at *virtual* store
paths:

    deploy-rs-activate -> /nix/store/4rjz8pif...-activate-path/deploy-rs-activate
    activate-rs        -> /nix/store/304c5g2x...-activate-rs/activate-rs

Those targets physically live under `/data/nix-store/nix/store/`, so the links dangle when
resolved from outside the chroot. Rust's `Path::exists()` follows symlinks, so the check can
never pass. **No flag fixes this** — it is structural.

Two ways out:

1. **Use `deployRebuildHdd`** for LAN hosts. `nixos-rebuild-ng` respects `NIX_REMOTE` and has
   no such check.
2. **Run deploy-rs against the SSD store** (plain `deploy .#server-vm`, no `NIX_REMOTE`) and
   `collectGarbage` afterwards. Costs SSD writes for one closure, keeps magic rollback.

A third option is patching out the two checks — they are only sanity checks, the build has
already succeeded, and the copy step (`nix copy --to ssh://…`, no `--from`) reads the default
store and so would work. `substituteInPlace src/push.rs --replace-fail "if !Path::new("
"if false && !Path::new("` in an overlay does it. Untested, and it disables validation that
the profile was built with `deploy-rs.lib.activate.nixos`.

### Which to use where

The tradeoff is lockout protection, not the store:

- **deploy-rs** defaults to `magicRollback = true` / `autoRollback = true` (not overridden in
  `flake.nix`). It activates, then waits for confirmation over a *fresh* SSH connection; if
  the new config breaks sshd, the firewall or networking, the target rolls itself back after
  `confirmTimeout`.
- **nixos-rebuild** runs `switch-to-configuration` and exits. Break networking and you need
  console access.

`server-vm` is `kopatz.dev` — remote, over the internet, no console. Keep it on plain
`deploy .#server-vm` (option 2 above) so magic rollback protects you; the SSD cost is one
server closure. The other three are on the LAN with a hypervisor console, so
`deployRebuildHdd` is fine for them.

Other differences: deploy-rs reads hostname/`sshUser` from `deploy.nodes` in `flake.nix`,
deploys all four nodes at once when given no target, and runs `deployChecks`. nixos-rebuild
takes the host on the CLI, does one at a time, and has no equivalent checks — but it
composes with `--build-host`, and `--store-path` accepts a prebuilt path (mutually
exclusive with `--flake`).

## kop-pc itself — build on HDD, copy to SSD

    nixSwitchHdd    # plain nix-env + switch-to-configuration
    nhSwitchHdd     # same, but nh does the activation and diff

Builds the local system into the HDD store, then copies only the **runtime closure** to the
SSD and activates it. Build-time-only paths (gcc, `-dev` outputs, source tarballs) never
touch the SSD — usually several times the size of the closure itself.

The copy is done by **piping an export into `sudo nix-store --import`**, not with
`nix copy`:

    nix-store --store /data/nix-store --export "${paths[@]}" | sudo nix-store --import

Both halves of that matter, and the obvious alternatives are both wrong:

- `sudo nix copy --from /data/nix-store --to daemon` fails with
  `cannot add path '...-hm_..zshrc' because it lacks a signature by a trusted key`.
  Locally built paths are unsigned, and being a trusted user only *permits* overriding
  `require-sigs` — it does not disable it. `nix-store --import` accepts unsigned paths, so
  no flag is needed.
- Worse, that command makes **root open the HDD store**, which corrupts its permissions.
  See the gotcha below. Piping over stdin keeps root away from it entirely: root only ever
  reads a byte stream.

Two further details, both load-bearing:

**Only export what the SSD lacks.** `nix copy` diffs against the destination and ships just
the missing paths; `--export` has no such logic and serialises whatever it is handed. Exporting
the whole closure therefore re-reads tens of GB off the HDD on *every* switch, even when
nothing changed — a full closure here is 3567 paths / ~38 GiB, and after a normal rebuild
essentially all of it is already on the SSD. `nix-store --check-validity --print-invalid`
against the daemon store gives the missing set, and reading the daemon store needs no sudo.

**Order and batching.** `nix-store -qR` emits paths in topological order, which `--import`
requires: each path's references must already exist or appear earlier in the stream. The
missing set is re-filtered through that ordered list rather than used directly, since
`--print-invalid` makes no ordering guarantee. It must also be a *single* `--export` call —
splitting across `xargs` invocations would concatenate independent streams and `--import`
would stop at the first terminator.

## Seeding the HDD store from the SSD

The two stores share nothing, so a fresh HDD store re-downloads everything. To avoid that,
copy a closure you already have across — local disk-to-disk beats re-fetching:

    nix copy --no-check-sigs --to /data/nix-store /nix/store/...-nixos-system-kop-pc-...

**`--no-check-sigs` is required.** Paths pulled from `cache.nixos.org` carry a signature and
copy fine, but anything NixOS generated locally (`etc-*`, `unit-*.target`, `vconsole.conf`, …)
has `"signatures":[]` and the destination store rejects it:

    error: cannot add path '...' because it lacks a signature by a trusted key

It is safe here — both stores are yours, and the source is already trusted. Note this is a
*different* problem from the `--to daemon` signature error in the section above: that one is
about `trusted-users`, this one is about the paths themselves being unsigned.

Beware that a partial copy exits non-zero but leaves whatever it managed to transfer, and
`nix copy … | tail` will mask the exit code. Check it explicitly.

## nh

`nh` works with the HDD store, but only if you split the build from the activation.

`NIX_REMOTE=/data/nix-store nh os build` does build into the HDD store and prints a correct
diff. Unlike deploy-rs it survives the chroot store, because it only `readlink`s its out-link
to get the path *string* and queries the store DB for the diff — it never stats files inside
the closure, so the dangling out-link is harmless.

`nh os switch` under `NIX_REMOTE` is a trap, though: **nh has no cross-store copy step.** It
would build on the HDD and then try to activate a path the SSD does not have. It also risks
handing `NIX_REMOTE` to root through its elevation strategy, which corrupts the store's
permissions (see the gotcha below).

`nhSwitchHdd` therefore builds and copies first, then passes the finished path to nh as a bare
store path installable — nh accepts those and resolves instantly instead of rebuilding:

    nh os switch /nix/store/...-nixos-system-kop-pc-...

The plain `updateFancy` (`nh os switch`) alias is untouched and still builds on the SSD.

## GC roots

GC roots for the HDD store live in **that store's** root dir, not the SSD's:

    /data/nix-store/nix/var/nix/gcroots/

and must point at the **virtual** path (`/nix/store/…`), not the physical one.
A root symlinked to `/data/nix-store/nix/store/…` is silently ignored.

This is what `add-gc-root.sh` does. Note the consequence: such a symlink looks *dangling*
to `ls`/`readlink`, because the virtual target doesn't exist on the SSD. That is expected —
`nix-store --gc --print-roots --store /data/nix-store` will confirm it is live.

`nix build --out-link` also works and registers a normal indirect root under
`gcroots/auto/` in the HDD store.

## Gotchas

- **`/data` is `nofail`.** If the HDD fails to mount, `--store /data/nix-store` silently
  creates a *fresh store on the root filesystem* — precisely what this setup avoids.
  `nixSwitchHdd` and `add-gc-root.sh` guard with `mountpoint -q /data`.
- **Never let root touch `/data/nix-store` at all** — not even read-only. Merely *opening*
  the store as root (e.g. `sudo nix copy --from /data/nix-store ...`) makes nix reinitialise
  the store directory to root-owned mode 1775, and every later unprivileged build then dies
  with:

      error: opening lock file '/data/nix-store/nix/store/....drv.lock': Permission denied

  Only the store *directory* flips; the paths inside stay `kopatz`-owned, so the fix is
  simply `sudo chown kopatz /data/nix-store/nix/store`. This is why the switch flow pipes an
  export into `sudo nix-store --import` instead of using `sudo nix copy --from`.
- Removing a chroot store needs the write bit restored first, since store paths are
  `dr-xr-xr-x`: `chmod -R u+w /data/nix-store && rm -rf /data/nix-store`.
- **Dependencies download twice**, once per store. You trade bandwidth and HDD space for
  SSD space. `optimiseHdd` dedupes within the HDD store.
- **The HDD spins down after 10 min** (`hdparm -S 120`, see `systems/pc/hardware-configuration.nix`).
  Expect a few seconds of spin-up on first access.
- The HDD store holds nothing the running system depends on — `rm -rf /data/nix-store`
  is always safe.
