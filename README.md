My NixOS setup

## options
I put my options under the `custom` key.

For example: `custom.graphical.plasma.enable = true;`

## pkgs
To build some of the custom pkgs you need a ssh key linked to github with access to my repos.

## building on the HDD
On `kop-pc`, other hosts are built into a chroot store on the spinning disk
(`/data/nix-store`) so their store paths never occupy the NVMe.
See [docs/hdd-store.md](docs/hdd-store.md).
