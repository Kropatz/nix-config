{pkgs, ...}: {
  tetrio = pkgs.callPackage ./tetrio-desktop/package.nix { };
  myKavita = pkgs.callPackage ./kavita { };
}
