{pkgs, ...}: {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
  hub = pkgs.callPackage ./hub/default.nix { };
}
