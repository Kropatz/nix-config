{pkgs, ...}: {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
  my-kavita = pkgs.callPackage ./kavita
}
