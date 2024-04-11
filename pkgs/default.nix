{pkgs, ...}: {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
}
